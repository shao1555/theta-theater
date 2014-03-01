#!/usr/bin/env ruby

$LOAD_PATH << './lib'

require 'rubygems'
require 'bundler'
Bundler.require

require 'theta_theater'
require 'sinatra/reloader' if development?

ENV['EDITOR'] ||= 'vim'

set :sprockets, Sprockets::Environment.new

global_config = Pit.get('theta_theater',
  require: {
    'consumer_key' => '',
    'consumer_secret' => '',
    'access_token' => '',
    'access_token_secret' => ''
  }
)

sprockets = Sprockets::Environment.new
Sprockets::Helpers.configure do |config|
  config.environment = sprockets
  config.prefix = '/assets'
  config.digest = true
end
sprockets.append_path 'assets/javascripts'
sprockets.append_path 'assets/stylesheets'

configure do
  set :sprockets, sprockets
  set :server, :thin
  set :environment, ENV['RACK_ENV'].to_sym
  set :urls, []
  set :sockets, []
  set :twitter_credential, {
    consumer_key: global_config['consumer_key'],
    consumer_secret: global_config['consumer_secret'],
    access_token: global_config['access_token'],
    access_token_secret: global_config['access_token_secret']
  }
  disable :run, :reload
end

helpers Sprockets::Helpers

require "#{File.dirname(__FILE__)}/app"

Tweet.settings = settings

# 自分の過去のタイムラインから theta360 の URL を取得
Tweet.fetch_all

# UserStream で新しくツイートされた theta360 の URL を取得
EM::defer { Tweet.stream_fetch }

map '/assets' do
  run sprockets
end
map '/' do
  run Sinatra::Application
end

