#!/usr/bin/env ruby

$LOAD_PATH << './lib'

require 'rubygems'
require 'bundler'
Bundler.require

require 'theta_theater'

ENV['EDITOR'] ||= 'vim'
global_config = Pit.get('theta_theater',
  require: {
    'consumer_key' => '',
    'consumer_secret' => '',
    'access_token' => '',
    'access_token_secret' => ''
  }
)

configure do
  set :server, :thin
  set :environment, ENV['RACK_ENV'].to_sym
  set :urls, []
  set :sockets, []
  disable :run, :reload
end

require "#{File.dirname(__FILE__)}/app"

# 過去データの取り込み
twitter_rest_client = Twitter::REST::Client.new do |config|
  config.consumer_key = global_config['consumer_key']
  config.consumer_secret = global_config['consumer_secret']
  config.access_token = global_config['access_token']
  config.access_token_secret = global_config['access_token_secret']
end

me = twitter_rest_client.user

twitter_rest_client.user_timeline(me.id).each do |tweet|
  tweet.urls.map(&:expanded_url).each do |uri|
    if uri.host == 'theta360.com' && uri.path =~ %r{^/s/}
      settings.urls << uri.to_s
    end
  end
end

# ストリーミング
twitter_streaming_client = Twitter::Streaming::Client.new do |config|
  config.consumer_key = global_config['consumer_key']
  config.consumer_secret = global_config['consumer_secret']
  config.access_token = global_config['access_token']
  config.access_token_secret = global_config['access_token_secret']
end

EM::defer do
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

run Sinatra::Application

