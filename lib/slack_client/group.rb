
require "slack_client/message"
require "slack_client/channel"

module SlackClient

  class Group < Channel

    def close
      params = { "channel" => @id }

      @client.apiCall 'groups.close', params, "_onClose"
    end

    def _onClose (data)
      @client.logger.debug data
    end

    def open
      params = {
        "channel" => @id
      }

      @client.apiCall 'groups.open', params, "_onOpen"
    end

    def _onOpen (data)
      @client.logger.debug data
    end

    def archive
      params = {
        "channel" => @id
      }

      @client.apiCall 'groups.archive', params, "_onArchive"
    end

    def _onArchive (data)
      @client.logger.debug data
    end

    def unarchive
      params = {
        "channel" => @id
      }

      @client.apiCall 'groups.unarchive', params, "_onUnArchive"
    end

    def _onUnArchive (data)
      @client.logger.debug data
    end

    def createChild
      params = {
        "channel" => @id
      }

      @client.apiCall 'groups.createChild', params, "_onCreateChild"
    end

    def _onCreateChild (data)
      @client.logger.debug data
    end

  end
end