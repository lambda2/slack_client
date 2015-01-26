

module SlackClient

  class Message

    attr_accessor :client, :id, :channel

    def initialize(client, data = {})
      @client = client

      data.each  do |name, value|
        self.class.send(:attr_accessor, name)
        instance_variable_set("@#{name}", value)
      end
    end

    def to_hash
      m = {}
      m['id'] = (@id or 1)
      m['type'] = (@type or 'message')
      m['channel'] = @channel
      m['text'] = @text
      m
    end

    def get_body
      txt = ""
      txt += @text if @text

      if @attachments
        txt += "\n" if @text
        @attachments.each do |k, attach|
          txt += "\n" if k > 0
          txt += attach["fallback"]
        end
      end
      return txt
    end

    def to_str
      return '' if @hidden || (!@text and !@attachments)

      str = ""
      # TODO: Date

      channel = @client.getChannelGroupOrDMByID @channel
      str += channel.name + ' > ' if channel

      user = @client.getUserByID @user
      if user
        str += user.name + ': '
      elsif @username
        str += @username
        if @client.getUserByName @username
          str += ' (bot): '
        else
          str += ': '
        end
      end

      # TODO: bots here

      str += getBody()

      str
    end

    def getChannelType
      channel = @client.getChannelGroupOrDMByID @channel
      return '' if not channel
      return channel.getType()
    end
  end
end