module RubyEventStore
  class Facade

    def initialize(repository)
      @repository = repository
    end
    attr_reader :repository

    def publish_event(event_data, stream_name = GLOBAL_STREAM, expected_version = nil)
      append_event_to_stream(event_data, stream_name, expected_version)
    end

    def delete_stream(stream_name)
      delete_stream_events(stream_name)
    end

    def read_events(stream_name, start, count)
      read_events_batch(stream_name, start, count)
    end

    def read_all_events(stream_name)
      read_all_stream_events(stream_name)
    end

    def read_all_streams
      read_all_events_from_store
    end

    def subscribe(subscriber, event_types)
      event_broker.add_subscriber(subscriber, event_types)
    end

    def subscribe_to_all_events(subscriber)
      event_broker.add_global_subscriber(subscriber)
    end

    private

    def append_event_to_stream(event_data, stream_name, expected_version)
      event = Actions::AppendEventToStream.new(repository).call(stream_name, event_data, expected_version)
      event_broker.notify_subscribers(event)
    end

    def delete_stream_events(stream_name)
      Actions::DeleteStreamEvents.new(repository).call(stream_name)
    end

    def read_events_batch(stream_name, start, count)
      Actions::ReadEventsBatch.new(repository).call(stream_name, start, count)
    end

    def read_all_stream_events(stream_name)
      Actions::ReadAllEvents.new(repository).call(stream_name)
    end

    def read_all_events_from_store
      Actions::ReadAllStreams.new(repository).call
    end

    def event_broker
      @event_broker ||= PubSub::Broker.new
    end
  end
end