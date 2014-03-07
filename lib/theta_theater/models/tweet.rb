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

      p 'fetch all tweets'
      twitter_rest_client.user_timeline(me.id).each do |tweet|
        theta_photo = ThetaPhoto.new(tweet)
        settings.theta_photos << theta_photo if theta_photo.valid?
        print '.'
      end
      p 'done.'
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
          theta_photo = ThetaPhoto.new(object)
          if theta_photo.valid?
            settings.theta_photos << theta_photo
            settings.sockets.each{|s| s.send(theta_photo.to_h.to_json) }
          end
        end
      end
    end
  end
end
