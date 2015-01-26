
module SlackClient

  class User

    attr_accessor :client

    def initialize (client, data = {})
      @client = client
      data.each do |name, value|
        self.class.send(:attr_accessor, name)
        instance_variable_set("@#{name}", value)
      end
    end

  end
end