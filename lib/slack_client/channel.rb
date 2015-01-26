
require "slack_client/message"

module SlackClient
  class Channel

    attr_accessor :history, :typing

    def initialize(client, data = {})
      @client = client
      @typing = {}
      @history = {}

      data.each  do |name, value|
        self.class.send(:attr_accessor, name)
        instance_variable_set("@#{name}", value)
      end
    end

    def get_type
      raise "Get type ?"
    end

    def addMessage (message)
      case message.subtype
        when nil, "channel_archive", "channel_unarchive", "group_archive", "group_unarchive"
          @history[message.ts] = message

        when "message_changed"
          @history[message.message.ts] = message.message

        when "message_deleted"
          @history[message.deleted_ts] = nil

        when "channel_topic", "group_topic"
          @topic.value = message.topic
          @topic.creator = message.user
          @topic.last_set = message.ts

          @history[message.ts] = message

        when "channel_purpose", "group_purpose"
          @purpose.value = message.purpose
          @purpose.creator = message.user
          @purpose.last_set = message.ts

          @history[message.ts] = message

        when "channel_name", "group_name"
          @name = message.name
          @history[message.ts] = message

        when "bot_message"
          # TODO: Make a new message type before storing
          @history[message.ts] = message

        when "channel_join", "group_join"
          @members.push message.user
          @history[message.ts] = message

        when "channel_leave", "group_leave"
          index = @members.indexOf message.user
          if index != -1
            @members.splice index
          end

          @history[message.ts] = message

        else
          @client.logger.debug "Unknown message subtype: %s", message.subtype
          @history[message.ts] = message
      end

      if message.ts and not message.hidden and @latest and @latest.ts and message.ts > @latest.ts
        @unread_count += 1
        @latest = message
      end

      mark message.ts if @client.autoMark

    end


    def send_text (text)
      m = Message.new @client, {text: text}
      send_message m
    end

    def send_message (message)
      message.channel = @id
      @client._send(message)
    end

  end
end