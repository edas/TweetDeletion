require "twitter"
require "json"

module TweetDeletion

  class Client
    
    def initialize(client)
      @client = client
    end

    def tester
      @tester ||= Tester.new(self)
    end

    def screen_name
      @screen_name ||= @client.user.screen_name
    end

    def for_favorites(&block)
      tweets = @client.favorites(count: 100)
      while tweets.any?
        to_delete = tweets.dup.delete_if do |tweet|
          tester.keep?(tweet, &block)
        end
        @client.unfavorite(*to_delete)
        tweets = @client.favorites(count: 100, max_id: tweets.last)
      end
    end

    def for_ids(ids, &block)
      ids.each_slice(99) do |slice|
        tweets = @client.statuses(*slice)
        to_delete = tweets.dup.delete_if do |tweet|
          tester.keep?(tweet, &block)
        end
        @client.destroy_status(*to_delete)
      end
    end

    def for_tweets(&block)
      tweets = @client.user_timeline(count: 100, include_rts: false, exclude_replies: false)
      while tweets.any?
        to_delete = tweets.dup.delete_if do |tweet|
          tester.keep?(tweet, &block)
        end
        @client.destroy_status(*to_delete)
        tweets = @client.user_timeline(count: 100, include_rts: false, exclude_replies: false, max_id: tweets.last)
      end
    end

    def for_retweets(&block)
      tweets = @client.retweeted_by_me(count: 100, exclude_replies: false)
      while tweets.any?
        to_delete = tweets.dup.delete_if do |tweet|
          tester.keep?(tweet, &block)
        end
        @client.destroy_status(*to_delete)
        tweets = @client.retweeted_by_me(count: 100, exclude_replies: false, max_id: tweets.last)
      end
    end

    def for_archive(dir, &block)
      js = File.read(File.join(dir, "data/js/tweet_index.js"))
      index = JSON.load(js.sub(/^.*?\[\s\{/, "[ {"))
      index.each do |part|
        file = File.join(dir, part["file_name"])
        for_archive_file(file, &block)
      end
    end

    def for_archive_file(file, &block)
      js = File.read(file)
      index = JSON.load(js.sub(/^.*?\[\s\{/, "[ {"))
      index.each do |attrs|  
        tweet = Twitter::Tweet.new(symbolize_keys(attrs))
        begin
          @client.destroy_status(tweet) if tester.keep?(tweet, &block)
        rescue Twitter::Error::NotFound
          # tweet already deleted, pass
        end
      end
    end

    def symbolize_keys!(object)
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

end
