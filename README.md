# TweetDeletion

TweetDeletion is a script who remove all yours tweets who does not match conditions.

## Installation

After checking out the repo, run the shell script `bin/setup` to install dependencies.
To install this gem onto your local machine, run `bundle exec rake install`.

## Usage

Create a script that uses TweetDeletion (see exemple_script.rb). You will need a Twitter Development account and to create an application on the [App Deshboard](https://apps.twitter.com/). Then you can create a config.yml file at the root of the folder and replace the `~` with your values:

```
yml
---
access_token: "~"
access_token_secret: "~"
consumer_key: "~"
consumer_secret: "~"
```

Create a script that uses TweetDeletion. You will need a Twitter Development account and to create an application on the [App Deshboard](https://apps.twitter.com/).

```ruby
require "tweet_deletion"

TweetDeletion.with(
  consumer_key: "…",
  consumer_secret: "…",
  access_token: "…",
  access_token_secret: "…",
) do 

  for_favorites do
    keep_if by(:me) 
    keep_if earlier_than( 10.days.ago )
    keep_if rt_by(:me)
  end 

  for_tweets do
    keep_if earlier_than( 10.days.ago )
    delete_if rt_of(:me) if is_rt
    keep_if fav_by(:me)
    keep_if has_kept_reply
    keep_if has_kept_quote
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
    unless is_rt
      keep_if rt_by_more_than( 15 ), tag: " 💯 "
      keep_if fav_by_more_than( 15 ), tag: " 💯 "
    end
    else_delete tag:" 🗑 "
  end

  for_retweets do
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

end
```

Then execute you script:

```ruby
ruby your_script.rb
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


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## My Contribution

Add a mode who delete only the tweets who match conditions with a dry mode 

````  
for_only_tweets(dry: true) do
        keep_if tweet_contains("text related"), tag: " 🔖 "
        keep_if rt_by_more_than(10)
end
````

## Contributing

Bug reports and pull requests are welcome on GitHub at [TweetDeletion](https://github.com/edas/TweetDeletion).


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
