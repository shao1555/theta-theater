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
  set :twitter_credential, {
    consumer_key: global_config['consumer_key'],
    consumer_secret: global_config['consumer_secret'],
    access_token: global_config['access_token'],
    access_token_secret: global_config['access_token_secret']
  }
  disable :run, :reload
end

require "#{File.dirname(__FILE__)}/app"

Tweet.settings = settings

# 過去データの取り込み
Tweet.fetch_all(settings: settings)

# ストリーミング
EM::defer { Tweet.stream_fetch(settings: settings) }

run Sinatra::Application

