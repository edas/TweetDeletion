# TweetDeletion

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/tweet_deletion`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

After checking out the repo, run `bin/setup` to install dependencies.
To install this gem onto your local machine, run `bundle exec rake install`.

## Credentials

Twitter: Create a script that uses TweetDeletion. You will need a Twitter Development account and to create an application on the [App Deshboard](https://apps.twitter.com/). You should have a consumer_key and a consumer_secret for the app, and an access_token and an access_token_secret per authorized account. If you already have an ap registered and try to authorize other accounts, `Twitter.authorize_request` and `Twitter.get_token` will help you manage that.

Mastodon: First register your app to have a client_id and client_secret, then use them to get a bearer_token per authorized account with your email and password. You will find some code on `Mastodon.register_and_get_token` to help you.

## Usage

```ruby
require "tweet_deletion"

accounts = [
  { 
    network: "twitter",
    consumer_key: "xxx",
    consumer_secret: "xxx",
    access_token: "xxx",
    access_token_secret: "xxx"
  },
  {
    network: "mastodon",
    bearer_token: "xxx"  
  }
]

TweetDeletion.with( accounts ) do 

  for_favorites do
    keep_if by(:me) 
    keep_if earlier_than( 10.days.ago )
    keep_if rt_by(:me)
  end 

  for_tweets(include_rts: true) do
    keep_if earlier_than( 10.days.ago )
    delete_if rt_of(:me) if is_rt
    keep_if fav_by(:me)
    keep_if has_kept_reply
    keep_if has_kept_quote
    keep_if is_direct_message
    unless is_rt
      keep_if rt_by_more_than( 50 )
      keep_if fav_by_more_than( 50 )
    end
  end

end
```

Or with emojis as visual feedback:

```ruby
require "tweet_deletion"

accounts = [
  { 
    network: "twitter",
    consumer_key: "xxx",
    consumer_secret: "xxx",
    access_token: "xxx",
    access_token_secret: "xxx"
  },
  {
    network: "mastodon",
    bearer_token: "xxx"  
  }
]

TweetDeletion.with(
  consumer_key: "…",
  consumer_secret: "…",
  access_token: "…",
  access_token_secret: "…",
) do 

  for_favorites do
    keep_if by(:me), tag:" 🗣 "
    keep_if earlier_than( 12.days.ago ), tag:" 📅 "
    keep_if rt_by(:me), tag:" 💬 "
    else_delete tag:" 🗑 "
  end 

  for_tweets(include_rts: true) do
    keep_if earlier_than( 10.days.ago ), tag:" 📅 "
    delete_if (is_rt and rt_of(:me)), tag:" 🗑 "
    keep_if fav_by(:me), tag: " ❤ ️"
    keep_if has_kept_reply, tag:" 💬 "
    keep_if has_kept_quote, tag:" 💬 "
    keep_if is_direct_message, tag: " 📩 "
    unless is_rt
      keep_if rt_by_more_than( 15 ), tag: " 💯 "
      keep_if fav_by_more_than( 15 ), tag: " 💯 "
    end
    else_delete tag:" 🗑 "
  end

end
```

Then execute you script:

```ruby
bundle exec your_script.rb
```

### Tweets from archive

Download your Twitter Archive and unzip it to pass the folder's path to a specific set of rules into your script:

```ruby
for_archive("./archive/") do
    keep_if earlier_than( 10.days.ago ), tag:" 📅 "
    delete_if (is_rt and rt_of(:me)), tag:" 🗑 "
    keep_if fav_by(:me), tag: " ❤ ️"
    keep_if has_kept_reply, tag:" 💬 "
    keep_if has_kept_quote, tag:" 💬 "
    unless is_rt
      keep_if rt_by_more_than( 15 ), tag: " 💯 "
      keep_if fav_by_more_than( 15 ), tag: " 💯 "
    end
    else_delete tag:" 🗑 "
end
```

## Actions and conditions

Inside the `for_*` blocks, you can use actions and conditions

### Actions

The first action to match will be used.

- `else_keep` keep your tweet
- `else_delete` delete your tweet
- `keep_if` keep your tweet if the parameter evaluates to `true`
- `delete_if` delete your tweet if the parameter evaluates to `true`
- `keep_unless` keep your tweet unless the parameter evaluates to `true`
- `delete_unless` delete your tweet unless the parameter evaluates to `true`

The optionnal `tag` named argument will display the corresponding tag in the console when the action is applied.

### Helpers

- `me` will return the current account name (without the leading "@")
- `tweet` will return an instance of `Status` with your tweet
- `mastodon` and `twitter` will return the current `Mastodon` or `Twitter` client instance 

### Conditions

- `by(user)` will match if the tweet is written by the given user 
- `earlier_than(date)` will match if the tweet has been written after the given date
- `older_than(date)`  will match if the tweet has been written before the given date
- `rt_by(:me)` will match if you retweeted the tweet
- `fav_by(:me)` will match if you favorited the tweet
- `is_rt` will match if the tweet is a retweet
- `links_to(url)` will match if the link (as a string) is present in the tweet (regexp are also allowed)
- `contains(match)` will match if the tweet contains the given string (regexp are also allowed)
- `rt_of(who)` will match if the original tweet was written by the given user
- `on_mastodon` and `on_twitter` will match is the current account is on the corresponding plateform
- `is_public`, `is_private`, `is_unlisted`, `is_direct_message` will match depending on the tweet visibility
- `has_media` will match if the tweet has an embedded image or media
- `has_kept_quote` will match if you decided to keep a message of yours which quote this tweet
- `has_kept_reply` will match if you decided to keep a message of yours which directly reply to this tweet. It will not follow indirect chains of tweets, if you reply to someone else's tweet which itself replies to a tweet you decided to keep: this will not match. However, if you consitently keep each message which has a reply from you, this rule will help you keep alive a whole thread provided you manage to keep the last one of the thread.


Users are expected in numeric (integer ids) or string (without the leading "@" but with the instance name on Mastodon). The magic value `:me` will match the current user.

For Twitter, a tweet is marked as private if the author account is protected, public otherwise.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Éric D./tweet_deletion.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

