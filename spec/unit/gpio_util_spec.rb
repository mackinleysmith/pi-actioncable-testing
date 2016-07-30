require 'spec_helper'
require_relative '../../lib/gpio_util'

RSpec.describe GpioUtil, type: :unit do
  let(:valid_pin) { 17 }

  subject { described_class.new pin: valid_pin }

  before do
    allow(Kernel).to receive(:system)
    allow(subject).to receive(:`)
  end

  describe 'BIN_PATH' do
    it 'points to a valid file' do
      expect(File.exists?(described_class::BIN_PATH)).to be
    end
  end

  describe '.new' do
    it 'requires a pin' do
      expect { described_class.new }.to raise_error ArgumentError
    end
  end

  describe '.write' do
    it 'requires a value' do
      expect { subject.write }.to raise_error ArgumentError
    end

    it 'calls system' do
      subject.write(value: 1)
      expect(Kernel).to have_received(:system)
    end
  end

  describe '.read' do
    it 'requires a block' do
      expect { subject.read }.to raise_error LocalJumpError
    end

    it 'calls the block passed to it with the value of the pin' do
      expect(subject).to receive(:read_from_pin).and_return 1

      expect {|b| subject.read(&b) }.to yield_with_args 1
    end

    it 'defaults to "read" mode, which uses backticks' do
      expect { subject.read {} }.not_to raise_error

      expect(subject).to have_received(:`) {|cmd| cmd =~ /-a read/ }
    end

    context 'when mode is wait_for_up' do
      it 'calls system' do
        subject.read(mode: 'wait_for_up') {}

        expect(Kernel).to have_received(:system)
      end
    end

    context 'when mode is wait_for_down' do
      it 'calls system' do
        subject.read(mode: 'wait_for_down') {}

        expect(Kernel).to have_received(:system)
      end
    end
  end

end