
module SlackClient

  class Team

    attr_accessor :client, :id, :name, :domain

    def initialize (client, id, name, domain)
      @client = client
      @id = id
      @name = name
      @domain = domain
    end

  end
end