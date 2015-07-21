require 'faye/websocket'
require 'multi_json'

require 'lita/adapters/facebook/event_loop'

module Lita
  module Adapters
    class Facebook < Adapter
      class RTMConnection

        class << self
          def build(robot, config)
            new(robot, config)
          end
        end

        def initialize(robot, config)
          @robot = robot
          @config = config

          # more init here
        end

        def run(queue = nil, options = {})
          EventLoop.run do
            log.debug("Connecting to Facebook node server")
            @websocket = Faye::WebSocket::Client.new(
              "ws://#{config.bridge_host}:#{config.bridge_port}"
            )

            websocket.on(:open) { log.debug("Connected to Facebook node server") }
            websocket.on(:message) { |event| receive_message(event) }
            websocket.on(:close) do
              log.info("Disconnected from Facebook node server")
              shut_down
            end

            websocket.on(:error) { |event| log.debug("Websocket error #{event.message}") }

            queue << websocket if queue
          end
        end

        def send_messages(source, strings)
          strings.each do |string|
            log.debug("Sending message #{source.inspect} - #{string.inspect}")
            EventLoop.defer { websocket.send(payload_for(source, string)) }
          end
        end

        def payload_for(source, string)

          thread_id = source.user.id if source.user
          thread_id = source.room if source.room

          url_match = /(http[s]?:\/\/.+?(?:png|jpg|gif))/.match(string)

          if url_match
            MultiJson.dump({
              type: 'attachment',
              body: string.gsub(/\S*http[s]?:\/\/.+?(?:png|jpg|gif)\S*/, ""),
              attachment: url_match[1],
              thread_id: thread_id
            })
          else
            MultiJson.dump({
              type: 'message',
              body: string,
              thread_id: thread_id
            })
          end


        end

        def shut_down
          if websocket
            log.debug("Closing connection to Facebook node server")
            websocket.close
          end

          EventLoop.safe_stop
        end

        private

        attr_reader :config
        attr_reader :robot
        attr_reader :websocket

        def log
          Lita.logger
        end

        def receive_message(event)
          data = MultiJson.load(event.data)
          log.debug("Received event - #{data.inspect}")

          EventLoop.defer { handle_message(data) }
        end

        def handle_message(msg)
          case msg['type']
          when "message"
            user_id = msg['sender_id']
            user_name = msg['sender_name']
            thread_id = msg['thread_id']
            body = msg['body']

            user = Lita::User.find_by_id(user_id)
            user = Lita::User.create(user_id, name: user_name) unless user
            source = Lita::Source.new(user: user, room: thread_id)
            message = Lita::Message.new(robot, body, source)

            robot.receive(message)
          end
        end

      end
    end
  end
end
