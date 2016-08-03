require 'spec_helper'
require_relative '../../lib/rgb_led'

RSpec.describe RgbLed, type: :unit do
  let(:red_pin) { 18 }
  let(:green_pin) { 23 }
  let(:blue_pin) { 24 }
  let(:mock_gpio_util) { double('GpioUtil', export: nil, unexport: nil, write: nil) }

  subject { RgbLed.new(red_pin: red_pin, green_pin: green_pin, blue_pin: blue_pin) }

  before { allow(GpioUtil).to receive(:new).and_return(mock_gpio_util) }

  it 'requires a red, green, and blue pin' do
    expect { described_class.new }.to raise_error ArgumentError
    expect { described_class.new red_pin: red_pin, green_pin: green_pin }.to raise_error ArgumentError
    expect { described_class.new red_pin: red_pin, blue_pin: blue_pin }.to raise_error ArgumentError
    expect { described_class.new green_pin: green_pin, blue_pin: blue_pin }.to raise_error ArgumentError
  end

  describe '#install!' do
    it 'creates a GpioUtil for each pin' do
      subject.install!

      expect(GpioUtil).to have_received(:new).once.with(pin: red_pin)
      expect(GpioUtil).to have_received(:new).once.with(pin: green_pin)
      expect(GpioUtil).to have_received(:new).once.with(pin: blue_pin)
    end

    it 'exports all pins as soft pwm outputs and writes 1' do
      subject.install!

      expect(mock_gpio_util).to have_received(:export).exactly(3).times.with(set_mode: 'soft_pwm')
      expect(mock_gpio_util).to have_received(:write).exactly(3).times.with(1)
    end
  end

  describe '#uninstall!' do
    it 'unexports all pins as outputs and writes 1' do
      subject.uninstall!

      expect(mock_gpio_util).to have_received(:write).exactly(3).times.with(1)
      expect(mock_gpio_util).to have_received(:unexport).exactly(3).times
    end
  end
end