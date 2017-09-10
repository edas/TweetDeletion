require "twitter"
require "json"
require "colorize"

module TweetDeletion

  class Client

    def initialize(client)
      @client = client
    end

    def log_group(txt)
      puts txt
      yield
      puts "\n\n"
    end

    def log_item(tag)
      $stdout.write tag
    end

    def log_end_category
      puts "\n\n"
    end

    def tester
      @tester ||= Tester.new(self)
    end

    def screen_name
      @screen_name ||= @client.user.screen_name
    end

    def for_favorites(dry: false, &block)
      log_group("For favorites") do
        tweets = @client.favorites(count: 100)
        while tweets.any?
          tweets.each do |tweet|
            if tester.keep?(tweet, &block)
              log_item(tester.tag)
            else
              if dry == false
                log_item(tester.tag)
                @client.unfavorite(tweet)
              else
                log_item(tester.tag)
                log_dry(tweet.text)
              end
            end
          end
          tweets = @client.favorites(count: 100, max_id: tweets.last.id - 1)
        end
      end
    end


    def for_ids(ids, &block)
      log_group("For ids…") do
        ids.each_slice(99) do |slice|
          tweets = @client.statuses(*slice)
          tweets.each do |tweet|
            begin
              if tester.keep?(tweet, &block)
                log_item(tester.tag)
              else
                if dry == false
                  log_item(tester.tag)
                  @client.destroy_status(tweet)
                else
                  log_item(tester.tag)
                  log_dry(tweet.text)
                end
              end
            rescue Twitter::Error::NotFound
              log_item(" ❓ ")
            rescue Twitter::Error::Unauthorized
              log_item(" 🕶️ ")
            end
          end
        end
      end
    end

    def for_tweets(include_rts: false, dry: false, &block)
      log_group("For tweets…") do
        tweets = @client.user_timeline(count: 100, include_rts: include_rts, exclude_replies: false)
        while tweets.any?
          tweets.each do |tweet|
            if tester.keep?(tweet, &block)
              log_item(tester.tag)
            else
              if dry == false
              log_item(tester.tag)
              @client.destroy_status(tweet)
              else
                log_dry ("\nREMOVE ::")
                log_dry (tweet.text)
              end
            end
          end
        end
      end
      tweets = @client.user_timeline(count: 100, include_rts: false, exclude_replies: false, max_id: tweets.last.id - 1)
    end


    def for_retweets(dry: false, &block)
      log_group("For retweets…") do
        tweets = @client.retweeted_by_me(count: 100, exclude_replies: false)
        while tweets.any?
          tweets.each do |tweet|
            if tester.keep?(tweet, &block)
              log_item(tester.tag)
            else
              if dry == false
                log_item(tester.tag)
                @client.destroy_status(tweet)
              else
                log_item(tester.tag)
                log_dry(tweet.text)
              end
            end
          end
          tweets = @client.retweeted_by_me(count: 100, exclude_replies: false, max_id: tweets.last.id - 1)
        end
      end
    end

    def for_archive(dir, &block)
      filepath = File.join(dir, "data/js/tweet_index.js")
      js = File.read(File.join(dir, "data/js/tweet_index.js"))
      index = JSON.load(js.sub(/^.*?\s*\[\s*\{/, "[ {"))
      index.each do |part|
        file = File.join(dir, part["file_name"])
        for_archive_file(file, &block)
      end
    end

    def for_archive_file(file, &block)
      js = File.read(file)
      index = JSON.load(js.sub(/^.*?\s*\[\s*\{/, "[ {"))
      tweet_ids = Array.new
      index.each do |attrs|
        tweet_ids.push symbolize_keys!(attrs)[:id]
      end
      puts for_ids(tweet_ids, &block)
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



    def for_only_tweets(dry: false, include_rts: false, &block)
      log_group("For only tweets…") do
        tweets = @client.user_timeline(count: 100, include_rts: include_rts, exclude_replies: false)
        while tweets.any?
          tweets.each do |tweet|
            if tester.keep?(tweet, &block)
              if dry == false
                log_item(tester.tag)
                @client.destroy_status(tweet)
              else
                puts "Remove".red
                puts tweet.text.red
              end
            else
              puts tweet.text.green
            end
          end
          tweets = @client.user_timeline(count: 100, include_rts: false, exclude_replies: false, max_id: tweets.last.id - 1)
        end
      end
    end






  end
end

