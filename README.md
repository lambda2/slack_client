# SlackClient

This is a Slack client library for Ruby. It is intended to expose all of the functionality of Slack's Real Time Messaging API while providing some common abstractions and generally making your life easier, if you want it to.

Actually, only the basics are implemented (Auth, Channels, Groups, DMs, Usera and Teams) and works with an EventMachine.
To see an example, see [Brobot](https://github.com/lambda2/Brobot)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'slack_client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install slack_client

## Usage

```ruby

require "slack_client"

class TestBot < SlackClient::Client

  # Called when the connexion is etablished with our amazing websockets
  def onOpen data
    print "Connexion opened !"
  end

  # Called when someone interact (new connexion, new message etc...)
  # All this types are in message["type"]
  # cf. https://api.slack.com/events
  def onMessage message
    print "We received a message ! #{message["text"]}"
    
    # We'll send a message back !
    channel = getChannelByName "some_chan"
    channel.send_text "Hello !"
    end
  end

end

```

## Contributing

1. Fork it ( https://github.com/lambda2/slack_client/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
