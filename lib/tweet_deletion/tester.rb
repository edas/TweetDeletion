require "active_support/time"

module TweetDeletion

  class Tester

    DEFAULT_TAG = "•"

    attr_reader :tweet
    attr_reader :tag
    

    def initialize(client)
      @keep = nil
      @client = client
      @tag = DEFAULT_TAG
      @kept = [ ]
      @kept_replied = [ ]
      @kept_quoted = [ ]
      @deleted = [ ]
      @deleted_replied = [ ]
      @deleted_quoted = [ ]
    end

    def keep?(tweet, &block)
      @tweet = tweet
      @keep = nil
      self.instance_eval(&block)
      @keep
    end

    def else_keep(tag:nil)
      keep!(tag:tag) if @keep.nil? 
    end

    def else_delete(tag:nil)
      delete!(tag:tag) if @keep.nil? 
    end
    
    def keep_if(arg, tag:nil, &block)
      if @keep.nil? 
        if block.nil?
          keep!(tag:tag) if arg
        else
          keep!(tag:tag) if self.instance_eval(&block)
        end
      end
    end

    def keep_unless(arg, tag:nil, &block)
      if @keep.nil? 
        if block.nil?
          delete!(tag:tag) if arg
        else
          delete!(tag:tag) if self.instance_eval(&block)
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

    def tweet_contains( keystring )
      tweet.text.include? keystring
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
      tweet.favorite_count >= nbr
    end

    def is_rt()
      tweet.retweet?
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

    def keep!(tag:nil)
      @tag = tag || "·"
      @keep = true
      @kept << tweet.id
      @kept_quoted << tweet.quoted_status.id
      @kept_replied << tweet.in_reply_to_status_id
    end

    def delete!(tag:nil)
      @tag = tag || "x"
      @keep = false
      @deleted << tweet.id
      @deleted_quoted << tweet.quoted_status.id
      @deleted_replied << tweet.in_reply_to_status_id
    end

  end 

end
