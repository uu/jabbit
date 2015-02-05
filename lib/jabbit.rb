require 'rubygems'
require 'xmpp4r-simple'
require 'bunny'
require 'json'
require 'settingslogic'
require 'openssl'
require_relative 'Jabbit/Settings'

class Jabbit

  def self.go!

    queue_name = 'xmpp_q'
    exchange_name = 'xmpp'

    if Settings.log_path
      log = Logger.new(Settings.log_path)
    else
      log = Logger.new(STDOUT)
    end

    log.datetime_format = '%Y-%m-%d %H:%M:%S'

    if Settings.debug
      log.level = Logger::Severity::DEBUG
    else
      log.level = Logger::Severity::INFO
    end

    log.info 'starting application'

    conn = Bunny.new(keepalive: true, user: Settings.amqp_user, pass: Settings.amqp_pass, host: Settings.amqp_host)
    conn.start

    log.debug 'created bunny connection'

    ch = conn.create_channel #ch.prefetch 1 # only one message at a time

    x = ch.fanout(exchange_name, durable: true)
    q = ch.queue(queue_name, {durable: true})
    q.bind(x)

    log.debug "created or obtained existed queue #{queue_name} and bind it to exchange #{exchange_name}"

    #robot = Jabber::Client::new(Jabber::JID::new(Settings.jabber_login))


    log.info 'Connecting to the jabber server...'
    robot = Jabber::Simple.new(Settings.jabber_login, Settings.jabber_pass)
    robot.status(:chat, Settings.status_message)
    #jabber_reconnect(robot)
    log.info 'connected' if robot

    q.subscribe(block: true, manual_ack: true) do |delivery_info, properties, payload|
      ack = lambda { ch.ack delivery_info[:delivery_tag], false }
      log.info "payload: #{payload}"
      log.debug 'payload: ' + payload.inspect
      begin
        json = JSON.parse(payload)
      rescue JSON::ParserError => error
        log.error("error in parsing some message for json? : \n\n #{payload} \n\n so we just ignore it and delete message")
        ch.ack delivery_info.delivery_tag
        raise error
      end

      begin
        #robot.send message
        log.info "Sending #{json['to']}"
        robot.deliver(json['to'], json['body'])
      rescue IOError
        log.warn "le' troubles in sending: #{json['to']}"
        sleep 5
        #jabber_reconnect(robot)
        ch.basic_recover(true)
      else
        log.info 'acknowledging message'
        ack.call
      end
    end

    log.info 'Disconnecting...'

    conn.close
  end
end

