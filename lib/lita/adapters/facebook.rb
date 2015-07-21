require 'lita/adapters/facebook/rtm_connection'


module Lita
  module Adapters
    class Facebook < Adapter
      config :bridge_host, type: String, required: true
      config :bridge_port, type: Integer, required: true

      def run
        return if rtm_connection
        @rtm_connection = RTMConnection.build(robot, config)
        rtm_connection.run
      end

      def send_messages(target, strings)
        return unless rtm_connection

        rtm_connection.send_messages(target, strings)
      end

      def shut_down
        return unless rtm_connection

        rtm_connection.shut_down
        robot.trigger(:disconnected)
      end

      private

      attr_reader :rtm_connection
    end

    Lita.register_adapter(:facebook, Facebook)
  end
end
