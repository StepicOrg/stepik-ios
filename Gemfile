source "https://rubygems.org"
ruby "2.6.5"

gem "fastlane", "2.174.0"
gem "cocoapods", "1.10.1"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
