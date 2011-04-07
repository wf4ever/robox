begin
  rvm_lib_path = File.expand_path("/usr/local/rvm/lib")
  $LOAD_PATH.unshift rvm_lib_path
  require 'rvm'
  RVM.use_from_path! File.dirname(File.dirname(__FILE__))
rescue LoadError
  # RVM is unavailable at this point.
  raise "RVM ruby lib is currently unavailable."
end

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])