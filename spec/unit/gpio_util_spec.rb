require 'spec_helper'
require_relative '../../lib/gpio_util'

RSpec.describe GpioUtil, type: :unit do
  let(:valid_pin) { 17 }

  subject { described_class.new pin: valid_pin }

  before do
    allow(subject).to receive(:system)
    allow(subject).to receive(:`)
  end

  def expect_gpio_received(expected_cmd)
    expect(subject).to have_received(:system).at_least(:once).with("gpio -g #{expected_cmd}")
  end

  describe '.new' do
    it 'requires a pin' do
      expect { described_class.new }.to raise_error ArgumentError
    end
  end

  describe '#export' do
    it 'calls the gpio to export the pin with a valid command' do
      subject.export

      expect_gpio_received "export #{valid_pin}"
    end

    it 'sets the mode to "out" by default' do
      subject.export

      expect_gpio_received "mode #{valid_pin} out"
    end

    it 'sets the mode to any specified set_mode key' do
      subject.export set_mode: 'in'

      expect_gpio_received "mode #{valid_pin} in"
    end
  end

  describe '#unexport' do
    before { allow(subject).to receive(:exported?).and_return true }

    it 'calls the gpio to unexport the pin with a valid command' do

      subject.unexport

      expect_gpio_received "unexport #{valid_pin}"
    end
  end

  describe '#write' do
    it 'requires a value' do
      expect { subject.write }.to raise_error ArgumentError
    end

    it 'calls the gpio with a valid command' do
      subject.write(value: 1)
      expect_gpio_received "write #{valid_pin} 1"
    end
  end

  describe '#read' do
    it 'uses backticks' do
      expect { subject.read }.not_to raise_error

      expect(subject).to have_received(:`) {|cmd| cmd =~ /-a read/ }
    end
  end

  describe '#wait_for' do
    it 'requires a block' do
      expect { subject.wait_for(1) }.to raise_error LocalJumpError
    end

    it 'calls the block passed to it with the value of the pin' do
      expect(subject).to receive(:read_from_pin).and_return 1

      expect {|b| subject.wait_for(1, &b) }.to yield_with_args 1
    end

    it 'calls gpio wfi with "rising" for 1' do
      subject.wait_for(1) {}

      expect_gpio_received "wfi #{valid_pin} rising"
    end

    it 'calls gpio wfi with "falling" for 0' do
      subject.wait_for(0) {}

      expect_gpio_received "wfi #{valid_pin} falling"
    end
  end

end