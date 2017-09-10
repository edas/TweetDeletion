require "tweet_deletion"
require 'yaml'
config = YAML.load_file('config.yml')

TweetDeletion.with(
    consumer_key: config["consumer_key"],
    consumer_secret: config["consumer_secret"],
    access_token: config["access_token"],
    access_token_secret: config["access_token_secret"],
) do

  for_only_tweets(dry: true) do
    keep_if tweet_contains("New Followers"), tag: " 🔖 "
    keep_if tweet_contains("Mention reach"), tag: " 🔖 "
    keep_if rt_by_more_than(10)
    keep_if older_than(10)
  end


end
