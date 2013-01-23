require 'rubygems'
require 'xmpp4r'
require 'bunny'
require 'json'
require 'settingslogic'
require 'openssl'
require_relative 'Jabbit/Settings'

class Jabbit

  def self.jabber_reconnect(cl)
    begin
      cl.connect Settings.jabber_host, Settings.jabber_port
      cl.auth(Settings.jabber_pass)
      cl.send(Jabber::Presence.new.set_show(:chat).set_status('your mom!'))
    rescue Errno::ECONNREFUSED
      log.warn "server sort of not respond. waiting..."
      sleep 5
      jabber_reconnect(cl)
    end
  end

  def self.go!

    queue_name = "xmpp_q"
    exchange_name = "xmpp"

    log = Logger.new(STDOUT)
    if Settings.debug
      log.level = Logger::Severity::DEBUG
    else
      log.level = Logger::Severity::INFO
    end

    log.info "starting application"

    conn = Bunny.new
    conn.start

    log.debug "created bunny connection"

    ch  = conn.create_channel #ch.prefetch 1 # only one message at a time

    x = ch.fanout(exchange_name, :durable => true)
    q = ch.queue(queue_name, {:durable => true})
    q.bind(x)

    log.debug "created or obtained existed queue #{queue_name} and bind it to exchange #{exchange_name}"

    robot = Jabber::Client::new(Jabber::JID::new(Settings.jabber_login))



    log.debug "initial connect to jabber server..."
    jabber_reconnect(robot)
    log.debug "connected"

    q.subscribe(:block => true, :ack => true) do |delivery_info, properties, payload|
      ack = lambda { ch.ack delivery_info[:delivery_tag], false }
      log.debug "payload: " + payload.inspect
      begin
        json = JSON.parse(payload)
      rescue JSON::ParserError => error
        log.error("error in parsing some message for json? : \n\n #{payload} \n\n so we just ignore it and delete message")
        ch.ack delivery_info.delivery_tag
        raise error
      end

      message = Jabber::Message::new(json["to"], json["body"])
      message.set_type(:chat)

      begin
        robot.send message
      rescue IOError
        log.warn "le' troubles in sending: "
        sleep 5
        jabber_reconnect(robot)
        ch.basic_recover(true)
      else
        log.debug "acknowledging message"
        ack.call
      end
    end

    puts "Disconnecting..."

    conn.close
  end
end

