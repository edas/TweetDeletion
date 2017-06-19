require "active_support/time"

module TweetDeletion

  class Tester

    attr_reader :tweet
    

    def initialize(client)
      @keep = nil
      @client = client
      @kept = [ ]
      @kept_replied = [ ]
      @kept_quoted = [ ]
      @deleted = [ ]
    end

    def keep?(tweet, &block)
      @tweet = tweet
      @keep = nil
      self.instance_eval(&block)
      @keep
    end

    def else_keep
      keep!
    end

    def else_delete
      delete!
    end

    def keep_if(arg, &block)
      if @keep.nil? 
        if block.nil?
          keep! if arg
        else
          keep! if self.instance_eval(&block)
        end
      end
    end

    def keep_unless(arg, &block)
      if @keep.nil? 
        if block.nil?
          delete! if arg
        else
          delete! if self.instance_eval(&block)
        end
      end
    end

    alias :delete_if :keep_unless
    alias :delete_unless :keep_if

    def by(who)
      who = @client.screen_name if who == :me
      tweet.user.screen_name == who
    end

    def earlier_than( date )
      tweet.created_at > date
    end

    def older_than( date )
      not earlier_than(date)
    end

    def rt_by(who)
      if who == :me
        tweet.retweeted?
      else
        raise
      end
    end
    
    def fav_by(who)
      if who == :me
        tweet.favorited?
      else
        raise
      end
    end

    def rt_by_more_than(nbr)
      tweet.retweet_count >= nbr
    end

    def fav_by_more_than(nbr)
      tweet_favorite_count >= nbr
    end

    def is_rt()
      not tweet.retweet?
    end

    def rt_of(who)
      who = @client.screen_name if who == :me
      tweet.retweet? and tweet.retweeted_status&.user&.screen_name == who
    end

    def has_kept_reply
      @kept_replied.include? tweet.id
    end

    def has_kept_quote
      @kept_quoted.include? tweet.id
    end

  private

    def keep!
      @keep = true
      @kept << tweet.id
      @kept_quoted << tweet.quoted_status.id
      @kept_replied << tweet.in_reply_to_status_id
    end

    def delete!
      @keep = false
      @deleted << tweet.id
      @deleted_quoted << tweet.quoted_status.id
      @deleted_replied << tweet.in_reply_to_status_id
    end

  end 

end
