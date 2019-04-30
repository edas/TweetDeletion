require "twitter"
require "twitter_oauth"

module TweetDeletion

  class Twitter < Client

    def instance_name 
      "twitter.com"
    end

    def initialize(options)
      super( ::Twitter::REST::Client.new { |config|
          config.consumer_key        = options[:consumer_key]
          config.consumer_secret     = options[:consumer_secret]
          config.access_token        = options[:access_token]
          config.access_token_secret = options[:access_token_secret]
        }
      )
    end

    def network
      :twitter
    end

    def yieldable_status(tweet)
      Tweet.new(tweet, me: account_id, instance: instance_name)
    end

    def with_user_favorites
      tweets = @client.favorites(count: default_slice, include_entities: true, tweet_mode: 'extended')
      while tweets.any?
        last_id = tweets.last.id
        tweets.each do |tweet|
          yield yieldable_status(tweet)
        end
        tweets = @client.favorites(count: default_slice, include_entities: true, tweet_mode: 'extended', max_id: last_id - 1)
      end
    end

    def unfavorite(tweet)
      @client.unfavorite(tweet)
    end

    def with_statuses_by_id(ids)
      ids.each_slice(default_slice) do |slice|
        tweets = @client.statuses(*slice, tweet_mode: 'extended')
        tweets.each do |tweet|
          yield yieldable_status(tweet)
        end
      end
    end

    def destroy_status(tweet)
      begin
        @client.destroy_status(tweet)
      rescue ::Twitter::Error::NotFound
        # Tweet ID is still in timeline
        # but cannot be deleted because
        # it is marked as already deleted
        # It may happen for RT of deleted tweets
        # or RT of blocked accounts
        # example : https://twitter.com/inclusicomps/status/843228546176864256
        # and RT as : https://twitter.com/edas/status/843374966141829120
        # Let's ignore it as we can't do anything with it anyways
      end
    end

    def with_user_statuses(include_rts: true, exclude_replies: false)
      tweets = @client.user_timeline(count: default_slice, include_rts: include_rts, include_entities: true, exclude_replies: exclude_replies, tweet_mode: 'extended')
      while tweets.any? 
        tweets.each do |tweet|
          yield yieldable_status(tweet)
        end
        tweets = @client.user_timeline(count: default_slice, include_rts: include_rts, include_entities: true, exclude_replies: exclude_replies, max_id: tweets.last.id - 1, tweet_mode: 'extended')
      end
    end

    def with_user_retweets
      tweets = @client.retweeted_by_me(count: 100, exclude_replies: false, include_entities: true, tweet_mode: 'extended')
      while tweets.any?
        tweets.each do |tweet|
          yield yieldable_status(tweet)
        end
        tweets = @client.retweeted_by_me(count: 100, exclude_replies: false, include_entities: true, max_id: tweets.last.id - 1, tweet_mode: 'extended')
      end
    end

    def screen_name
      @screen_name ||= @client.user.screen_name
    end

    def account_name
      screen_name
    end

    def account_id
      @user_id ||= @client.user.id
    end

    def me
      account_id
    end

    def default_slice
      100
    end

    def for_archive(dir, dry: false, &block)
      filepath = File.join(dir, "data/js/tweet_index.js")
      js = File.read(filepath)
      index = JSON.load(js.sub(/^.*?\s*\[\s*\{/, "[ {"))
      index.each do |part|
        file = File.join(dir, part["file_name"])
        for_archive_file(file, dry: dry, &block)
      end
    end

    def for_archive_file(file, dry: false, &block)
      js = File.read(file)
      index = JSON.load(js.sub(/^.*?\s*\[\s*\{/, "[ {"))
      tweet_ids = index.map { |attrs| attrs["id"] }
      for_ids(tweet_ids, dry: dry, &block)
    end

    def self.authorize_request(consumer_key:, consumer_secret:)
      oauth = TwitterOAuth::Client.new(consumer_key: consumer_key, consumer_secret: consumer_secret)
      req = oauth.request_token
      puts "Request token: #{req.token}"
      puts "Request secret: #{req.secret}"
      puts "Go to #{req.authorize_url} and feed the resulting code to `.get_token`"
    end

    def self.get_token(consumer_key:, consumer_secret:, request_token:, request_secret:, code: )
      oauth = TwitterOAuth::Client.new(consumer_key: consumer_key, consumer_secret: consumer_secret)
      access = oauth.authorize(request_token, request_secret, :oauth_verifier => code)
      puts "Your access_token: #{access.token}"
      puts "Your access_token_secret: #{access.secret}"
    end

  end

end
