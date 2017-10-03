require "tweet_deletion"
require 'yaml'
config = YAML.load_file('config.yml')

TweetDeletion.with( accounts ) do

  for_tweets(include_rts: false, dry: true) do
    keep_if contains("New Followers"), tag: " 🔖 "
    keep_if contains("Mention reach"), tag: " 🔖 "
    keep_if rt_by_more_than(10)
    keep_if older_than(10)
  end


end
