require "tweet_deletion/version"
require "twitter"
require "tweet_deletion/client"
require "tweet_deletion/tester"

module TweetDeletion
  
  def self.with(*args, consumer_secret:, consumer_key:, access_token:, access_token_secret:, &block)
    client = Client.new( 
      Twitter::REST::Client.new do |config|
        config.consumer_key        = consumer_key 
        config.consumer_secret     = consumer_secret
        config.access_token        = access_token
        config.access_token_secret = access_token_secret
      end
    )
    client.instance_exec(*args, &block)
  end

end
