require "tweet_deletion"
require 'yaml'
config = YAML.load_file('./config.yml')

TweetDeletion.with( accounts ) do

  for_favorites do

    keep_if contains("[Veille]"), tag:" 🔖 "
    keep_if contains("DareBoost"), tag:" 🚀 "

    keep_if by(:me), tag:" 🗣 "
    keep_if earlier_than( 12.days.ago ), tag:" 📅 "
    keep_if rt_by(:me), tag:" 💬 "
    else_delete tag:" 🗑 "
  end

  for_tweets(include_rts: true) do

    keep_if contains("[Veille]"), tag:" 🔖 "
    keep_if contains("DareBoost"), tag:" 🚀 "

    keep_if earlier_than( 10.days.ago ), tag:" 📅 "
    delete_if (is_rt and rt_of(:me)), tag:" 🗑 "
    keep_if fav_by(:me), tag: " ❤ ️"
    keep_if has_kept_reply, tag:" 💬 "
    keep_if has_kept_quote, tag:" 💬 "
    unless is_rt
      keep_if rt_by_more_than( 5 ), tag: " 💯 "
      keep_if fav_by_more_than( 5 ), tag: " 💯 "
    end
    else_delete tag:" 🗑 "
  end

  for_retweets do

    keep_if contains("[Veille]"), tag:" 🔖 "
    keep_if contains("DareBoost"), tag:" 🚀 "

    keep_if earlier_than( 10.days.ago ), tag:" 📅 "
    delete_if (is_rt and rt_of(:me)), tag:" 🗑 "
    keep_if fav_by(:me), tag: " ❤ ️"
    keep_if has_kept_reply, tag:" 💬 "
    keep_if has_kept_quote, tag:" 💬 "
    unless is_rt
      keep_if rt_by_more_than( 5 ), tag: " 💯 "
      keep_if fav_by_more_than( 5 ), tag: " 💯 "
    end
    else_delete tag:" 🗑 "
  end

  for_archive("./archive/") do

    keep_if contains("[Veille]"), tag:" 🔖 "
    keep_if contains("DareBoost"), tag:" 🚀 "

    keep_if earlier_than( 10.days.ago ), tag:" 📅 "
    delete_if (is_rt and rt_of(:me)), tag:" 🗑 "
    keep_if fav_by(:me), tag: " ❤ ️"
    keep_if has_kept_reply, tag:" 💬 "
    keep_if has_kept_quote, tag:" 💬 "
    unless is_rt
      keep_if rt_by_more_than( 5 ), tag: " 💯 "
      keep_if fav_by_more_than( 5 ), tag: " 💯 "
    end
    else_delete tag:" 🗑 "
  end
end