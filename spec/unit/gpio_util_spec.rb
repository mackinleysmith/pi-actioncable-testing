require 'spec_helper'
require_relative '../../lib/gpio_util'

RSpec.describe GpioUtil, type: :unit do
  let(:valid_pin) { 17 }

  subject { described_class.new pin: valid_pin }

  before { allow(Kernel).to receive(:system) }

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
    it 'defaults to "read" mode' do
      expect(subject).to receive(:command_pin!) {|cmd| cmd =~ /-a read/ }

      expect { subject.read }.not_to raise_error
    end

    it 'calls system' do
      subject.read
      expect(Kernel).to have_received(:system)
    end
  end

end