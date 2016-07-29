require 'action_cable_client'

class CableManager
  DEFAULT_ACTIONCABLE_URI = 'ws://localhost:3000/cable'

  def initialize(channel_name, uri: DEFAULT_ACTIONCABLE_URI, &reception_callback)
    @channel_name = channel_name
    @uri = uri
    @reception_callback = reception_callback
  end

  def connect!
    install_hooks!
  end

  def follow!
    perform 'follow'
  end

  def unfollow!
    perform 'unfollow'
  end

  protected

  def handle_connection
    puts "Connected to #{channel_name}"
  end

  def handle_subscription
    puts "Subscribed to #{channel_name}"
    follow!
  end

  def handle_reception(msg)
    puts "Message received from #{channel_name}: #{msg}"
    reception_callback.(msg)
  end

  def handle_disconnection
    puts "Disconnected from #{channel_name}"
    unfollow!
  end

  def handle_error(msg)
    puts "Error for #{channel_name}: #{msg}"
  end

  private
  attr_reader :channel_name, :uri, :reception_callback

  def channel
    @channel ||= ActionCableClient.new uri, channel_name
  end

  def install_hooks!
    channel.connected { handle_connection }
    channel.subscribed { handle_subscription }
    channel.received {|msg| handle_reception(msg) }
    channel.disconnected { handle_disconnection }
    channel.errored {|msg| handle_error(msg) }
  end

  def perform(action, options={})
    channel.perform action, options
  end
end