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
  def expect_gpio_not_called
    expect(subject).not_to have_received(:system).with(/^gpio/)
  end
  def expect_gpio_not_called_with(unexpected_cmd)
    expect(subject).not_to have_received(:system).with("gpio -g #{unexpected_cmd}")
  end

  def expect_pi_blaster_received(expected_cmd)
    expect(subject).to have_received(:system).at_least(:once).with("echo \"#{expected_cmd}\" > /dev/pi-blaster")
  end
  def expect_pi_blaster_not_called
    expect(subject).not_to have_received(:system).with(/> \/dev\/pi-blaster$/)
  end
  def expect_pi_blaster_not_called_with(unexpected_cmd)
    expect(subject).not_to have_received(:system).with("echo \"#{unexpected_cmd}\" > /dev/pi-blaster")
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

    it 'calls unexport if the pin was previously exported in a different mode' do
      allow(subject).to receive(:exported?).and_return(true)
      expect(subject).to receive(:unexport)

      subject.export set_mode: 'in'
    end

    context 'when mode is soft_pwm' do
      it 'calls out to pi-blaster instead of gpio' do
        subject.export set_mode: 'soft_pwm'

        expect_gpio_not_called
        expect_pi_blaster_received "#{valid_pin}=1"
      end
    end
  end

  describe '#unexport' do
    before { allow(subject).to receive(:exported?).and_return true }

    it 'calls the gpio to unexport the pin with a valid command' do
      subject.unexport

      expect_gpio_received "unexport #{valid_pin}"
    end

    context 'when mode is soft_pwm' do
      it 'calls out to pi-blaster instead of gpio' do
        allow(subject).to receive(:mode).and_return('soft_pwm')

        subject.unexport

        expect_gpio_not_called
        expect_pi_blaster_received "release #{valid_pin}"
      end
    end
  end

  describe '#write' do
    it 'requires a value' do
      expect { subject.write }.to raise_error ArgumentError
    end

    it 'calls the gpio with a valid command' do
      subject.write value: 1
      expect_gpio_received "write #{valid_pin} 1"
    end

    context 'when mode is soft_pwm' do
      it 'calls out to pi-blaster instead of gpio' do
        allow(subject).to receive(:mode).and_return('soft_pwm')

        subject.write value: 1

        expect_gpio_not_called
        expect_pi_blaster_received "#{valid_pin}=1"
      end
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