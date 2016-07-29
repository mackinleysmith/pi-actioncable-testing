require 'spec_helper'
require_relative '../../lib/cable_manager'

RSpec.describe CableManager do
  let(:channel_name) { 'Test Channel' }
  let(:default_uri) { described_class::DEFAULT_ACTIONCABLE_URI }
  let(:mock_client) { spy('ActionCableClient') }

  subject { described_class.new(channel_name) }

  before do
    allow(ActionCableClient).to receive(:new).and_return(mock_client)
  end

  describe '#perform' do
    it 'calls #perform on the ActionCableClient instance' do
      subject.perform('something', {foo: 'bar'})

      expect(mock_client).to have_received(:perform).with('something', {foo: 'bar'})
    end
  end

  describe '#connect!' do
    it 'returns self' do
      expect(subject.connect!).to eq subject
    end

    it 'initializes an ActionCableClient with the specified channel name' do
      subject.connect!

      expect(ActionCableClient).to have_received(:new).with(default_uri, channel_name)
    end

    it 'initializes an ActionCableClient with the specified uri' do
      described_class.new(channel_name, uri: 'http://something.com').connect!

      expect(ActionCableClient).to have_received(:new).with('http://something.com', channel_name)
    end

    it 'calls #connected, which calls #handle_connection' do
      allow(subject).to receive(:handle_connection)

      subject.connect!

      expect(mock_client).to have_received(:connected).with(no_args) do |*_, &block|
        block.()
        expect(subject).to have_received(:handle_connection)
      end
    end

    it 'calls #subscription, which calls #handle_subscription, which calls #follow!' do
      allow(subject).to receive(:handle_subscription)

      subject.connect!

      expect(mock_client).to have_received(:subscribed).with(no_args) do |*_, &block|
        allow(subject).to receive(:handle_subscription).and_call_original
        allow(subject).to receive(:follow!)

        block.()
        expect(subject).to have_received(:handle_subscription)
        expect(subject).to have_received(:follow!)
      end
    end

    it 'calls #received, which calls #handle_reception, which calls the reception_callback' do
      mock_reception_callback = proc {}
      expect(mock_reception_callback).to receive(:call).with('Some Message')
      subject = described_class.new(channel_name, &mock_reception_callback)
      allow(subject).to receive(:handle_reception).and_call_original

      subject.connect!

      expect(mock_client).to have_received(:received).with(no_args) do |*_, &block|
        block.('Some Message')
        expect(subject).to have_received(:handle_reception)
      end
    end

    it 'calls #disconnected, which calls #handle_disconnection, which calls #unfollow!' do
      allow(subject).to receive(:handle_disconnection)

      subject.connect!

      expect(mock_client).to have_received(:disconnected).with(no_args) do |*_, &block|
        allow(subject).to receive(:handle_disconnection).and_call_original
        allow(subject).to receive(:unfollow!)

        block.()

        expect(subject).to have_received(:handle_disconnection)
        expect(subject).to have_received(:unfollow!)
      end
    end

    it 'calls #errored, which calls handle_error' do
      allow(subject).to receive(:handle_error)

      subject.connect!

      expect(mock_client).to have_received(:errored).with(no_args) do |*_, &block|
        block.()
        expect(subject).to have_received(:handle_error)
      end
    end
  end

  describe '#follow!' do
    it 'calls #perform on the ActionCableClient' do
      subject.follow!

      expect(mock_client).to have_received(:perform).with('follow', {})
    end
  end

  describe '#unfollow!' do
    it 'calls #perform on the ActionCableClient' do
      subject.unfollow!

      expect(mock_client).to have_received(:perform).with('unfollow', {})
    end
  end
end