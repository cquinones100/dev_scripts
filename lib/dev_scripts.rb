require "dev_scripts/version"

module DevScripts
  class Error < StandardError; end
end

require 'dev_scripts/scripts/open_spec_file'
require 'dev_scripts/scripts/rubocop_metrics_method_length'

DevScripts::Script.execute(ARGV)