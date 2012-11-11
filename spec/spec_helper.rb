# -- coding: utf-8

require "rubygems"
require "bundler/setup"
Bundler.require :default, :test, :development
require "rspec-expectations"
require "rspec/matchers/built_in/be"

Dir["./spec/support/**/*.rb"].each{|file| require file }

require File.expand_path("../../lib/autopagerize.rb", __FILE__)

RSpec.configure do |config|
end
