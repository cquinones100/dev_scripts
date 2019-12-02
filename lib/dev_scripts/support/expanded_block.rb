require 'parser/current'
require 'dev_scripts/support/block'
require 'dev_scripts/support/method_call'

module DevScripts
  module Support
    class ExpandedBlock < String
      def initialize(line:)
        parsed = Parser::CurrentRuby.parse(line).children
        spacing = line.match(/\A\s*/)[0]
        end_spacing = line.match(/\s*\z/)[0]
        block_string = DevScripts::Support::Block.new(parsed[1], parsed[2])
        block_lines = block_string.split("\n")

        self << spacing + DevScripts::Support::MethodCall.new(parsed[0])
        self << ' '
        self << block_lines[0]
        self << "\n"
        self << spacing + block_lines[1]
        self << "\n"
        self << spacing + block_lines[2]
        self << end_spacing
      end
    end
  end
end
