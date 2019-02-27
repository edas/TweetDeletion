module TweetDeletion

class Status


  def initialize(status, instance:nil, me:nil)
    @status = status
    @instance = instance
    @me = me
  end

  def raw
    @status
  end

  def instance
    @instance
  end

  def self.alternative_name(new, old)
    define_method(new) do 
      self.__send__(old)
    end
  end

  def rt?
    raise
  end
  alternative_name :retweet?, :rt?
  alternative_name :retoot?, :rt?
  alternative_name :reblog?, :rt?


  def retweeted?
    raise
  end
  alternative_name :retooted?, :retweeted?
  alternative_name :reblogged?, :retweeted?
  alternative_name :retweeted_by_me?, :retweeted?
  alternative_name :retooted_by_me?, :retweeted?
  alternative_name :reblogged_by_me?, :retweeted?

  def user_id
    raise
  end
  alternative_name :account_id, :user_id

  def user_name
    raise
  end
  alternative_name :account_name, :user_name
  alternative_name :screen_name, :user_name

  def retweeted_status
    raise
  end
  alternative_name :retweeted_tweet, :retweeted_status
  alternative_name :reblogged_status, :retweeted_status
  alternative_name :retooted_status, :retweeted_status
  alternative_name :retooted_toot, :retweeted_status
  alternative_name :reblogged_toot, :retweeted_status
  alternative_name :reblog, :retweeted_status
  alternative_name :rt, :retweeted_tweet
  
  def in_reply?
    raise
  end

  def in_reply_to
    raise
  end
  alternative_name :in_reply_to_status_id, :in_reply_to
  alternative_name :in_reply_to_id, :in_reply_to

  def in_reply_to_user_id
    raise
  end
  alternative_name :in_reply_to_account_id, :in_reply_to_user_id

  def favorited?
    raise
  end
  alternative_name :liked?, :favorited?
  alternative_name :fav?, :favorited?
  alternative_name :fav_by_me?, :favorited?
  alternative_name :favourited?, :favorited?


  def fav_count
    raise
  end
  alternative_name :fav_count, :favorites_count
  alternative_name :favorite_count, :favorites_count
  alternative_name :favourites_count, :favorites_count
  alternative_name :favourite_count, :favorites_count
  alternative_name :like_count, :favorites_count

  def rt_count
    raise
  end
  alternative_name :retweets_count, :rt_count
  alternative_name :retweet_count, :rt_count
  alternative_name :retoots_count, :rt_count
  alternative_name :retoot_count, :rt_count
  alternative_name :reblogs_count, :rt_count
  alternative_name :reblog_count, :rt_count

  def text_content
    raise
  end
  alternative_name :content, :text_content
  alternative_name :text, :text_content

  def html_content
    raise
  end
  alternative_name :html, :html_content

  def created_at
    raise
  end

  def id
    raise
  end

  def quote?
    raise
  end
  alternative_name :has_quote?, :quote?

  def quoted_id
    raise
  end
  alternative_name :quoted_status_id, :quoted_id
  alternative_name :quoted_tweet_id, :quoted_id
  alternative_name :quoted_toot_id, :quoted_id

  def visibility
    raise
  end

  def public?
    visibility == :public
  end

  def unlisted?
    visibility == :unlisted
  end

  def private?
    visibility == :private
  end

  def direct?
    visibility == :direct
  end
  alternative_name :direct_message?, :direct?
  alternative_name :dm?, :direct? 

  def links
    raise
  end

  def has_media?
    raise
  end

end

end