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
      @kept = []
      @kept_replied = []
      @kept_quoted = []
      @deleted = []
      @deleted_replied = []
      @deleted_quoted = []
    end

    def keep?(tweet, &block)
      @tweet = tweet
      @keep = nil
        self.instance_eval(&block)
      @keep
    end

    def else_keep(tag: nil)
      keep!(tag: tag) if @keep.nil?
    end

    def else_delete(tag: nil)
      delete!(tag: tag) if @keep.nil?
    end

    def keep_if(arg, tag: nil, &block)
      if @keep.nil?
        if block.nil?
          keep!(tag: tag) if arg
        else
          keep!(tag: tag) if self.instance_eval(&block)
        end
      end
    end

    def keep_unless(arg, tag: nil, &block)
      if @keep.nil?
        if block.nil?
          delete!(tag: tag) if arg
        else
          delete!(tag: tag) if self.instance_eval(&block)
        end
      end
    end

    alias :delete_if :keep_unless
    alias :delete_unless :keep_if

    def by(who)
      who = @client.me if who == :me
      if who.kind_of? Numeric
        who == tweet.user_id
      else
        who == tweet.user_name
      end
    end

    def earlier_than(date)
      tweet.created_at > date
    end

    def older_than(date)
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
      tweet.rt_count >= nbr
    end

    def fav_by_more_than(nbr)
      tweet.fav_count >= nbr
    end

    def is_rt()
      tweet.rt?
    end

    def links_to(match)
      match = Regexp.new("^#{Regexp.quote(match)}$") if match.kind_of? String
      tweet.links.find { |link| link.match(match) }
    end

    def contains(match)
      match = Regexp.quote(match) if match.kind_of? String
      tweet.text.match(match)
    end

    def rt_of(who)
      if is_rt
        rt = tweet.retweeted_status
        who = @client.me if who == :me
        if who.kind_of? Numeric
          who == rt.user_id
        else
          who == rt.user_name
        end
      else
        false
      end
    end

    def has_kept_reply
      @kept_replied.include? tweet.id
    end

    def has_kept_quote
      @kept_quoted.include? tweet.id
    end

    def on_mastodon
      @client.network == :mastodon
    end

    def on_twitter
      @client.network == :twitter
    end

    def me
      @client.account_name
    end

    def is_public
      tweet.public?
    end

    def is_private
      tweet.private?
    end

    def is_unlisted
      tweet.unlisted?
    end

    def is_direct_message
      tweet.direct?
    end
    alias_method :is_dm, :is_direct_message


    def twitter
      twitter? && @client
    end

    def mastodon
      mastodon? && @client
    end

    def has_media
      tweet.has_media?
    end

  private

    def keep!(tag: nil)
      @tag = tag || "·"
      @keep = true
      @kept << tweet.id
      @kept_quoted << tweet.quoted_id if tweet.quote?
      @kept_replied << tweet.in_reply_to if tweet.reply?
    end

    def delete!(tag: nil)
      @tag = tag || "x"
      @keep = false
      @deleted << tweet.id
      @deleted_quoted << tweet.quoted_id if tweet.quote?
      @deleted_replied << tweet.in_reply_to if tweet.reply?
    end

  end

end
