class GpioUtil
  def initialize(pin:, mode: 'out')
    @pin = pin
    @mode = mode
    @exported = false
  end

  def using_soft_pwm?
    mode == 'soft_pwm'
  end

  def export(set_mode: @mode)
    return if exported? && set_mode == mode

    unexport if exported?
    @mode = set_mode

    if using_soft_pwm?
      command_pi_blaster! "#{pin}=1"
    else
      command_pin! 'export'
      command_pin! 'mode', mode
    end

    @exported = true
  end

  def unexport
    return unless exported?

    if using_soft_pwm?
      command_pi_blaster! "release #{pin}"
    else
      command_pin! 'unexport'
    end

    @exported = false
  end

  def write(value:)
    export unless exported?

    if using_soft_pwm?
      command_pi_blaster! "#{pin}=#{value}"
    else
      command_pin! 'write', value
    end
  end

  def read
    export(set_mode: 'in') unless exported?
    read_from_pin
  end

  def wait_for(value, with_mode: nil)
    export(set_mode: 'in') unless exported?
    export(set_mode: with_mode) if with_mode

    command_pin! 'wfi', case value
      when 0 then 'falling'
      when 1 then 'rising'
    end

    yield read_from_pin
  end

  protected

  def command_pin!(command, values=nil)
    command_gpio! "#{command} #{pin} #{values}".strip
  end

  def command_pi_blaster!(cmd)
    system "echo \"#{cmd}\" > /dev/pi-blaster"
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