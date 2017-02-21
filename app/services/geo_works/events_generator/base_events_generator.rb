module GeoWorks
  class EventsGenerator
    class BaseEventsGenerator
      def initialize(messaging_client)
        @messaging_client = messaging_client
      end

      private

        def base_message(type, record)
          {
            "id" => record.id,
            "event" => type
          }
        end

        def publish_message(message)
          @messaging_client.publish(message.to_json)
        end
    end
  end
end
