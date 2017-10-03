require "twitter"
require "json"

module TweetDeletion

  class Client
    
    def initialize(client)
      @client = client
      puts "******************\n** For #{account_name} / #{network.to_s} … …"
      log_end_category
    end

    def log_group(txt) 
      puts txt
      yield
      log_end_category
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

    def for_favorites(&block)
      log_group("For favorites") do
        with_user_favorites do |tweet|
          if tester.keep?(tweet, &block)
            log_item(tester.tag)
          else
            log_item(tester.tag)
            unfavorite(tweet.id) 
          end
        end
      end
    end

    def for_ids(ids, &block)
      log_group("For ids…") do
        with_statuses_by_id(ids) do |tweet|
          begin
            if tester.keep?(tweet, &block)
              log_item(tester.tag)
            else
              log_item(tester.tag)
              destroy_status(tweet.id)
            end
          rescue ::Twitter::Error::NotFound
            log_item("?")
          rescue ::Twitter::Error::Unauthorized
            log_item("!")
          end
        end
      end
    end

    def for_tweets(include_rts: true, &block)
      log_group("For tweets/toots/statuses…") do
        with_user_statuses(include_rts: include_rts, exclude_replies: false) do |tweet|
          if tester.keep?(tweet, &block)
            log_item(tester.tag)
          else
            log_item(tester.tag)
            destroy_status(tweet.id)
          end
        end
      end
    end

    # Deprecated
    def for_retweets(&block)
      log_group("For retweets/reblogs…") do
        with_user_retweets(include_rts: include_rts, exclude_replies: false) do |tweet|
          if tester.keep?(tweet, &block)
            log_item(tester.tag)
          else
            log_item(tester.tag)
            destroy_status(tweet.id)
          end
        end
      end
    end

    alias_method :for_messages, :for_tweets
    alias_method :for_statuses, :for_tweets
    alias_method :for_toots, :for_tweets
    alias_method :for_retoots, :for_retweets
    alias_method :for_reblogs, :for_retweets



  end

end
