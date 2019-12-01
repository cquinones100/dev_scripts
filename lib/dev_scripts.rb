require "dev_scripts/version"

module DevScripts
  class Error < StandardError; end
end

require 'dev_scripts/scripts/open_spec_file'
require 'dev_scripts/scripts/rubocop_metrics_method_length'

if File.exist? './dev_scripts'
  Dir['./dev_scripts/**/*.rb'].each do |file|
    require file
  end
end

DevScripts::Script.execute(ARGV)