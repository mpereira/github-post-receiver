require 'rubygems'
require 'json'
require 'sinatra'
require 'active_support/core_ext/hash/indifferent_access'
require File.expand_path('../github_post_receiver', __FILE__)

run GithubPostReceiver
