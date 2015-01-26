require 'logger'
require "json"
require "net/https"
require "uri"
require "event_emitter"
require 'faye/websocket'
require 'eventmachine'

require "slack_client/user"
require "slack_client/team"
require "slack_client/channel"
require "slack_client/group"
require "slack_client/message"
require "slack_client/dm"

module SlackClient

  class Client

    include EventEmitter

    def initialize token, auto_reco = true, auto_mark = true
      @token = token
      @auto_reco = auto_reco
      @auto_mark = auto_mark
      @authenticated = false
      @connected = false

      @self = nil
      @team = nil

      @channels = {}
      @dms = {}
      @groups = {}
      @users = {}
      @bots = {}

      @socket = nil
      @ws = nil
      @message = 0
      @_pending = {}

      @_conn = 0

      @logger = Logger.new(STDOUT)
      @logger.level = Logger::INFO
    end

    def login
      @logger.info 'Connecting...'
      apiCall('rtm.start', {agent: 'ruby-slack'}, :on_login)
    end

    def on_login (data)
      if data
        unless data["ok"]
          # emit 'error', data["error"]
          @authenticated = false
        else
          @authenticated = true

          # Important information about ourselves
          # puts data[:self]
          @self = User.new(self, data["self"])
          @team = Team.new(self, data["team"]["id"], data["team"]["name"], data["team"]["domain"])

          # Stash our websocket url away for later -- must be used within 30 seconds!
          @socketUrl = data["url"]

          # Stash our list of other users (DO THIS FIRST)
          data["users"].each{|user| @users[user["id"]] = User.new(self, user)}

      #     # Stash our list of channels
          data["channels"].each{|channel| @channels[channel["id"]] = Channel.new(self, channel)}

          # Stash our list of dms
          data["ims"].each{|ims| @dms[ims["id"]] = DM.new(self, ims)}

          # Stash our list of private groups
          data["groups"].each{|group| @groups[group["id"]] = Group.new(self, group)}

          # TODO: Process bots

          self.emit 'loggedIn', @self, @team
          puts "ready to connect !"
          connect()
        end
      else
        emit 'error', data
        @authenticated = false
        reconnect() if @autoReconnect
      end
    end

    # ======================= CALLBACKS =======================

    def onOpen
    end

    def onMessage message
    end

    def onError error
    end

    # ======================= CONNEXIONS =======================

    def connect
      unless @socketUrl
        return false
      else
        p "Socketurl: #{@socketUrl}"
        @ws = Faye::WebSocket::Client.new @socketUrl

        @ws.on :open do |event|
          puts "open !"
          self.emit 'open'
          @connected = true
          @_connAttempts = 0
        end

        @ws.on :message do |event|
          # flags.binary will be set if a binary data is received
          # flags.masked will be set if the data was masked
          puts "> #{event.data}"
          onMessage JSON.parse(event.data)
        end

        @ws.on :error do |event|
          # TODO: Reconnect?
          self.emit 'error'
        end

        @ws.on :close do |event|
          self.emit 'close'
          @connected = false
          @socketUrl = nil
        end

        return true
      end
    end


    # ======================= UTILITIES ==========================


    def getUserByID (id)
      @users[id]
    end


    def getUserByName (name)
      @users.map{|id, u| u if u.name.to_s == name.to_s}.compact.first
    end


    def getChannelByID (id)
      @channels[id]
    end


    def getChannelByName (name)
      @channels.map{|id, u| u if u.name.to_s == name.to_s}.compact.first
    end


    def getDMByID (id)
      @dms[id]
    end


    def getDMByName (name)
      @dms.map{|id, u| u if u.name.to_s == name.to_s}.compact.first
    end


    def getGroupByID (id)
      @groups[id]
    end


    def getGroupByName (name)
      @groups.map{|id, u| u if (u.name == name)}.compact.first
    end


    def getChannelGroupOrDMByID (id)
      return getChannelByID(id) if id[0] == 'C'
      return getGroupByID(id) if id[0] == 'G'
      return getDMByID(id)
    end


    def getChannelGroupOrDMByName (name)
      channel = getChannelByName(name)
      p "Requested channel (#{name}) => #{channel}"
      unless channel
        group = getGroupByName(name)
        p "Requested group (#{name}) => #{group}"
        return getDMByName(name) unless group
        return group
      else
        return channel
      end
    end


    # def getUnreadCount
    #   count = 0
    #   for id, channel of @channels
    #     if channel.unread_count? then count += channel.unread_count

    #   for id, dm of @ims
    #     if dm.unread_count? then count += dm.unread_count

    #   for id, group of @groups
    #     if group.unread_count? then count += group.unread_count

    #   count


    # end


    # def getChannelsWithUnreads
    #   unreads = []
    #   for id, channel of @channels
    #     if channel.unread_count? then unreads.push channel

    #   for id, dm of @ims
    #     if dm.unread_count? then unreads.push dm

    #   for id, group of @groups
    #     if group.unread_count? then unreads.push group

    #   unreads
    # end

    def _send (message)
      unless @connected
        return false
      else
        message.id = (@messageID += 1)
        @_pending[message.id] = message
        json = JSON.generate(message.to_hash)
        p "Ready to send #{json}"
        @ws.send json
      end
    end

    alias :send_message :_send

    def apiCall (method, params, callback)
      uri = URI("https://api.slack.com/api/#{method}")
      res = Net::HTTP.post_form(uri, params.merge({token: @token}))
      self.send callback, JSON.parse(res.body)
    end

  end

EventEmitter.apply Client

end
