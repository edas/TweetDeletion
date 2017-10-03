require 'mastodon'
require 'oauth2'

module TweetDeletion

  class Mastodon < Client

    SCOPE = 'read write follow'


    def initialize(options)
      @instance = options[:instance]
      super ::Mastodon::REST::Client.new(
        base_url: options[:instance], 
        bearer_token: options[:bearer_token]
      )
    end

    def network
      :mastodon
    end

    def yieldable_status(toot)
      Toot.new(toot, me: account_id, instance: instance_name)
    end

    def account
      @account ||= @client.verify_credentials
    end

    def with_user_favorites
      tweets, max_id = get_favorites(count: default_slice)
      while tweets.any?
        last_id = tweets.last.id
        tweets.each do |tweet|
          yield yieldable_status(tweet)
        end
        if max_id
          tweets, max_id = get_favorites(count: default_slice, max_id: max_id)
        else
          tweets = [ ]
        end
      end
    end

    def get_favorites(count: default_slice, max_id: nil)
      options = { limit: default_slice }
      options[:max_id] = max_id if max_id
      req = ::Mastodon::REST::Request.new(@client, :get, "/api/v1/favourites", options)
      options_key = @request_method == :get ? :params : :form
      headers = req.instance_variable_get(:@headers)
      uri = req.instance_variable_get(:@uri)
      response = req.__send__(:http_client).headers(headers).public_send(:get, uri.to_s, options_key => options)
      data = req.__send__(:fail_or_return, response.code, response.body.empty? ? '' : response.parse)
      [
        ::Mastodon::Collection.new(data, ::Mastodon::Status),
        next_max_id(response["link"])
      ]
    end

    def next_max_id(header)
      /max_id=(\d+)[^>]*>;\s*rel=["']?next['"]?/.match(header)&.[](1)
    end

    def unfavorite(tweet)
      @client.unfavourite(tweet)
    end

    def with_statuses_by_id(ids)
      ids.each do |id|
        tweet = @client.status(id)
        yield yieldable_status(tweet) if tweet
      end
    end

    def destroy_status(tweet)
      @client.destroy_status(tweet)
    end

    def with_user_statuses(include_rts: true, exclude_replies: false)
      options = { limit: default_slice }
      # Mastodon server seems to consider any value for `exclude_replies` as a "yes"
      # even if we send `false` or `0`
      # workaround: only include the key when we want to set it to `true` 
      options[:exclude_replies] = true if exclude_replies
      tweets = @client.statuses(account_id, options)
      while tweets.any? 
        tweets.each do |tweet|
          toot = yieldable_status(tweet)
          yield toot if include_rts || !toot.rt?
        end
        options[:max_id] = tweets.last.id - 1
        tweets = @client.statuses(account_id, options)
      end
    end

    def with_user_retweets
      with_user_statuses(include_rts: true, exclude_replies: false) do |tweet|
        toot = yieldable_status(tweet)
        yield toot if toot.rt?
      end
    end

    def account_name
      "#{account.acct}@#{instance_name}"
    end

    def account_id
      account.id
    end

    def me
      account_id
    end

    def instance_name
      @instance.gsub(/.*\/([^\/]+).*/, "\\1")
    end

    def default_slice
      100
    end

    def user_timeline(count: default_slice, include_rts: false, exclude_replies: false, max_id: nil)
      @client.user_timeline(count: count, include_rts: include_rts, exclude_replies: exclude_replies, max_id: max_id)
    end

    def self.register_app(name="tweet_deletion", website:nil, instance:)
      client = ::Mastodon::REST::Client.new(base_url: instance)
      client.create_app(name, "urn:ietf:wg:oauth:2.0:oob", SCOPE, website)
    end

    def self.get_token(client_id:, client_secret:, login:, password:, instance:)
      oauth = OAuth2::Client.new(client_id, client_secret, site: instance)
      oauth.password.get_token(login, password, scope: SCOPE)
    end

    def self.register_and_get_token(name="tweet_deletion", website:nil, instance:, login:, password:)
      app = register_app(name, website:website, instance:instance)
      token = get_token(client_id:app.client_id, client_secret:app.client_secret, login:login, password:password, instance:instance)
      token.token
    end

  end

end
