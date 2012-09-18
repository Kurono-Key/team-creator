require 'bundler'
Bundler.require

require './main.rb'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/dev.db')

run Sinatra::Application
