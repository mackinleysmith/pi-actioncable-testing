require 'spec_helper'

class CableManager
  DEFAULT_ACTIONCABLE_URI = 'ws://localhost:3000/cable'

  def initialize(channel_name, uri: DEFAULT_ACTIONCABLE_URI)
    @channel_name = channel_name
    @uri = uri
  end

  def connect!
    channel.connected { puts 'HI' }
    true
  end

  private
  attr_reader :channel_name, :uri

  def channel
    @channel ||= ActionCableClient.new uri, channel_name
  end
end

RSpec.describe CableManager do
  let(:channel_name) { 'Test Channel' }
  let(:default_uri) { described_class::DEFAULT_ACTIONCABLE_URI }
  let(:mock_client) { double('ActionCableClient', connected: nil) }

  subject { described_class.new(channel_name) }

  describe '#connect!' do
    before do
      allow(ActionCableClient).to receive(:new).and_return(mock_client)
    end

    it 'initializes an ActionCableClient with the specified channel name' do
      subject.connect!

      expect(ActionCableClient).to have_received(:new).with(default_uri, channel_name)
    end

    it 'initializes an ActionCableClient with the specified channel name' do
      described_class.new(channel_name, uri: 'http://something.com').connect!

      expect(ActionCableClient).to have_received(:new).with('http://something.com', channel_name)
    end

    it ''
  end
end