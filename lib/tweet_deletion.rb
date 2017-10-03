require "tweet_deletion/version"
require "tweet_deletion/client"
require "tweet_deletion/twitter"
require "tweet_deletion/mastodon"
require "tweet_deletion/status"
require "tweet_deletion/tweet"
require "tweet_deletion/toot"
require "tweet_deletion/tester"
require "twitter"
module TweetDeletion
  
  def self.with(arg, &block)
    symbolize_keys!(arg)
    if arg.respond_to?(:has_key?) and arg.has_key?(:access_token_secret)
      # old API, one account only, twitter only
      arg = [ arg ]
    elsif arg.kind_of? Hash
      arg = arg.values
    end
    for account in arg
      next if account[:deactivated]
      client = case account[:network]&.to_s&.downcase
      when "twitter" then Twitter
      when "mastodon" then Mastodon
      else 
        account.has_key?(:access_token_secret) ? Twitter : Mastodon
      end
      begin
        client.new(account).instance_exec([], &block)
      rescue ::Twitter::Error::Forbidden
        puts "!!! FORBIDDEN \n\n" 
      rescue ::Twitter::Error::Unauthorized
        puts "!!! UNAUTHORIZED \n\n"
      end
    end
  end

  def self.symbolize_keys!(object)
    if object.is_a?(Array)
      object.each_with_index do |val, index|
        object[index] = symbolize_keys!(val)
      end
    elsif object.is_a?(Hash)
      object.keys.each do |key|
        object[key.to_sym] = symbolize_keys!(object.delete(key))
      end
    end
    object
  end

end
