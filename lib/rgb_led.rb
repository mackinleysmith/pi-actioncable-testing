require_relative 'gpio_util'

class RgbLed

  def initialize(red_pin:, green_pin:, blue_pin:)
    @red_pin = red_pin
    @green_pin = green_pin
    @blue_pin = blue_pin
  end

  def install!
    pins.each{|pin| pin.export(set_mode: 'soft_pwm'); pin.write(value: 1) }
  end

  def uninstall!
    pins.each{|pin| pin.write(value: 1); pin.unexport }
  end

  def set(r:, g:, b:)
    set_red(r)
    set_green(g)
    set_blue(b)
  end

  def go_red!
    set r: 1, g: 0, b: 0
  end
  def go_green!
    set r: 0, g: 1, b: 0
  end
  def go_blue!
    set r: 0, g: 0, b: 1
  end

  private
  attr_reader :red_pin, :green_pin, :blue_pin

  def red
    @red ||= GpioUtil.new(pin: red_pin, mode: 'soft_pwm')
  end

  def green
    @green ||= GpioUtil.new(pin: green_pin, mode: 'soft_pwm')
  end

  def blue
    @blue ||= GpioUtil.new(pin: blue_pin, mode: 'soft_pwm')
  end

  def pins
    [red, green, blue]
  end

  def set_pin(pin, value)
    pin.write(value: corrected_value(value))
  end

  def set_red(value)
    set_pin red, value
  end
  def set_green(value)
    set_pin green, value
  end
  def set_blue(value)
    set_pin blue, value
  end

  def corrected_value(value)
    # Add modes later maybe.
    (1.0 - value.to_f).abs
  end
end