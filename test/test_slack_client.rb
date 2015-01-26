require 'minitest/autorun'
require 'slack_client'

class SlackClientTest < Minitest::Test
  def test_simple_instance
    a = SlackClient::Client.new "XXXX"
    assert_true a != nil
  end
end