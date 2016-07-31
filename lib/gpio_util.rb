class GpioUtil
  BIN_PATH = File.expand_path('../../bin/gpio_util', __FILE__)

  def initialize(pin:, mode: 'out')
    @pin = pin
    @mode = mode
    @exported = false
  end

  def export(set_mode: @mode)
    return if exported? && set_mode == mode
    command_pin! 'export'
    command_pin! 'mode', set_mode
    @mode = set_mode
    @exported = true
  end

  def unexport
    return unless exported?
    command_pin! 'unexport'
    @exported = false
  end

  def write(value:)
    export(set_mode: 'out')
    command_pin! 'write', value
  end

  def read
    read_from_pin
  end

  def wait_for(value, with_mode: nil)
    export(set_mode: 'in')
    export(set_mode: with_mode) if with_mode

    command_pin! 'wfi', case value
      when 0 then 'falling'
      when 1 then 'rising'
    end

    yield read_from_pin
  end

  protected

  def command_pin!(command, values=nil)
    command_gpio! "#{command} #{pin} #{values}"
  end

  def read_from_pin
    `#{formulate_command "read #{pin}"}`
  end

  private
  attr_reader :pin, :mode, :exported
  alias exported? exported

  def command_gpio!(command)
    system formulate_command(command)
  end

  def formulate_command(command)
    "gpio -g #{command}"
  end

end