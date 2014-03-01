class Tweet
  class << self
    def settings=(settings)
      @settings = settings
    end

    def settings
      @settings
    end

    def fetch_all
      twitter_rest_client = Twitter::REST::Client.new do |config|
        config.consumer_key = settings.twitter_credential[:consumer_key]
        config.consumer_secret = settings.twitter_credential[:consumer_secret]
        config.access_token = settings.twitter_credential[:access_token]
        config.access_token_secret = settings.twitter_credential[:access_token_secret]
      end

      me = twitter_rest_client.user

      twitter_rest_client.user_timeline(me.id).each do |tweet|
        p tweet.media
        tweet.urls.map(&:expanded_url).each do |uri|
          if uri.host == 'theta360.com' && uri.path =~ %r{^/s/}
            settings.urls << uri.to_s
          end
        end
      end
    end

    def stream_fetch
      twitter_streaming_client = Twitter::Streaming::Client.new do |config|
        config.consumer_key = settings.twitter_credential[:consumer_key]
        config.consumer_secret = settings.twitter_credential[:consumer_secret]
        config.access_token = settings.twitter_credential[:access_token]
        config.access_token_secret = settings.twitter_credential[:access_token_secret]
      end

      twitter_streaming_client.user do |object|
        case object
        when Twitter::Tweet
          object.urls.map(&:expanded_url).each do |uri|
            if uri.host == 'theta360.com' && uri.path =~ %r{^/s/}
              settings.sockets.each{|s| s.send(uri.to_s) }
              settings.urls.unshift(uri.to_s)
              puts uri.to_s
            end
          end
        end
      end

    end
  end
end
