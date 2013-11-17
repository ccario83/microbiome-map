require 'sinatra'
require 'slim'
require 'sass'
require 'coffee-script'
#require 'mongo'
require 'json'
require 'sinatra/reloader' if development?

#include Mongo
#client   = MongoClient.new('localhost', 27017)
#$db      = client['atp-db']
#listings = $db['listings']

require './app'
run App