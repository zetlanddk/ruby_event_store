require 'spec_helper'

module Test
  class TestCreated < RubyEventStore::Event
  end
end

module RubyEventStore
  describe Event do

    specify 'for empty data it initializes instance with default values' do
      event = Test::TestCreated.new
      expect(event.event_type).to eq  'Test::TestCreated'
      expect(event.event_id).to_not   be_nil
      expect(event.metadata).to       eq({})
      expect(event.data).to           eq({})
    end

    specify 'UUID should be String' do
      event_1 = Test::TestCreated.new({event_id: 1})
      event_2 = Test::TestCreated.new
      expect(event_1.event_id).to be_an_instance_of(String)
      expect(event_2.event_id).to be_an_instance_of(String)
    end

    specify 'UUID should be unique' do
      event_1 = Test::TestCreated.new
      event_2 = Test::TestCreated.new
      expect(event_1.event_id).to_not eq(event_2.event_id)
    end

    specify 'UUID should look like an UUID' do
      event = Test::TestCreated.new
      uuid_regexp = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
      expect(event.event_id).to match(uuid_regexp)
    end

    specify 'convert to hash' do
      event_data = {
          event_type: 'OrderCreated',
          data: { data: 'sample' },
          event_id: 'b2d506fd-409d-4ec7-b02f-c6d2295c7edd',
          metadata: { meta: 'test'}
      }
      event = Test::TestCreated.new(event_data)
      expect(event.to_h[:event_type]).to eq 'OrderCreated'
      expect(event.to_h[:event_id]).to eq 'b2d506fd-409d-4ec7-b02f-c6d2295c7edd'
      expect(event.to_h[:data]).to eq({ data: 'sample' })
      expect(event.to_h[:metadata][:meta]).to eq('test')
      expect(event.to_h[:metadata][:published_at]).to be_a Time
    end

    specify 'convert to hash with default Time metadata' do
      now = Time.parse('2015-05-04 15:17:11 +0200')
      utc = Time.parse('2015-05-04 13:17:23 UTC')
      allow_any_instance_of(Time).to receive(:now).and_return(now)
      allow_any_instance_of(Time).to receive(:utc).and_return(utc)
      event_data = {
          event_type: 'OrderCreated',
          data: { data: 'sample' },
          event_id: 'b2d506fd-409d-4ec7-b02f-c6d2295c7edd',
      }
      event = Test::TestCreated.new(event_data)
      expect(event.to_h[:event_type]).to eq 'OrderCreated'
      expect(event.to_h[:event_id]).to eq 'b2d506fd-409d-4ec7-b02f-c6d2295c7edd'
      expect(event.to_h[:metadata][:published_at]).to eq utc
      expect(event.to_h[:data]).to eq({ data: 'sample' })
    end
  end
end
