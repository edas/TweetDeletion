require 'cgi'

module TweetDeletion

class Tweet < Status

  def rt?
    @status.retweet?
  end

  def retweeted?
    @status.retweeted?
  end

  def user_id
    @status.user.id
  end

  def user_name
    @status.user.screen_name
  end

  def retweeted_status
    @status.retweeted_status ? self.class.new(@status.retweeted_status, me: @me) : nil
  end
  
  def reply?
    @status.in_reply_to_status_id
  end

  def in_reply_to
    @status.in_reply_to_status_id
  end

  def in_reply_to_user_id
    @status.in_reply_to_user_id
  end

  def in_reply_to_user_name
    @status.in_reply_to_screen_name
  end
  
  def favorited?
    @status.favorited?
  end

  def fav_count
    @status.favorite_count
  end

  def rt_count
    @status.retweet_count
  end

  def text_content
    @status.attrs[:full_text]
  end

  def html_content
    "<p>#{CGI::escapeHTML(text_content).gsub(/\n/, "\\0<br>")}</p>"
  end

  def created_at
    @status.created_at
  end

  def id
    @status.id
  end

  def quote?
    !! @status.quoted_status
  end

  def quoted_id
    @status.quoted_status.id
  end

  def visibility
    @status.retweet? || !@status.user.protected? ? :public : :private
  end

  def links
    @status.urls.map { |data| data.expanded_url.to_s }
  end

  def has_media?
    @status.media.any?
  end

end

end
