require "slack_client/message"
require "slack_client/channel"

module SlackClient

  class DM < Channel

    def initialize(client, data = {})

      super(client, data)

      if @user
        u = @client.getUserByID @user
        @name = u.name if u
      end
    end

    def close
      params = {"channel" => @id}

      @client.apiCall 'im.close', params, "_onClose"
    end

    def _onClose (data)
      @client.logger.debug data
    end

  end
end
