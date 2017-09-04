# TweetDeletion

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/tweet_deletion`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

After checking out the repo, run `bin/setup` to install dependencies.
To install this gem onto your local machine, run `bundle exec rake install`.

## Usage

Create a script that uses TweetDeletion (see exemple_script.rb). You will need a Twitter Development account and to create an application on the [App Deshboard](https://apps.twitter.com/). Then you can create a config.yml file at the root of the folder and replace the `~` with your values:

```yml
--- 
access_token: "~"
access_token_secret: "~"
consumer_key: "~"
consumer_secret: "~"
```

Then execute you script:

```ruby
ruby your_script.rb
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Éric D./tweet_deletion.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

