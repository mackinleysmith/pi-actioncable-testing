class GpioUtil
  BIN_PATH = File.expand_path('../bin/gpio_util', __FILE__)

  def initialize(pin:)
    @pin = pin
  end

  def write(value:)
    command_pin! pin, value
  end

  def read(mode: 'read')
    command_pin! pin, "-d in -m down -a #{mode}"
  end

  private
  attr_reader :pin

  def command_pin!(pin, command)
    Kernel.system "#{BIN_PATH} -p #{pin} #{command}"
  end
end