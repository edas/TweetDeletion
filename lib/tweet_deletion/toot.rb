require 'cgi'
require 'loofah'

module TweetDeletion

class Toot < Status

  def rt?
    !! @status.attributes["reblog"]
  end

  def retweeted?
    @status.reblogged? or (rt? and user_id == @me)
  end

  def user_id
    @status.account.id
  end

  def user_name
    acct = @status.account.acct
    acct.match("@") ? acct : "acct@#{@instance}"
  end

  def retweeted_status
    @status.reblog ? self.class.new(@status.reblog, instance: @instance, me: @me) : nil
  end
  
  def reply?
    @status.in_reply_to_id
  end

  def in_reply_to
    @status.in_reply_to_id
  end

  def in_reply_to_user_id
    @status.in_reply_to_account_id
  end

  def in_reply_to_user_name
    raise
  end
  
  def favorited?
    rt? ? retweeted_status.favorited? : @status.favourited?
  end

  def fav_count
    @status.favourites_count
  end

  def rt_count
    @status.reblogs_count
  end

  def text_content
    doc = Loofah.fragment(html_content)
    doc.xpath(".//script",".//form","comment()").remove
    doc.to_text
  end

  def html_content
    @status.content
  end

  def created_at
    Time.parse(@status.created_at)
  end

  def id
    @status.id
  end

  def quote?
    false
  end

  def quoted_id
    nil
  end

  def visibility
    @status.attributes["visibility"].to_sym
  end

  def links
    html_content.match(/href=['"]?([^'">\s]+)["']?[\s>]/)&.captures || [ ]
  end

  def has_media?
    @status.media_attachments.any?
  end

end

end