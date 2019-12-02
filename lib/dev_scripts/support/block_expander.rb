module DevScripts
  module Support
    class BlockExpander

      def initialize(line:)
        @line = line
        @body = line.match(/\{.*}\s*\n*\z/)&.send(:[], 0)
        @spacing = line.match(/\A\s*/)&.send(:[], 0)
        @argument = line.match(/\|\w+(,\w+)*\|/)&.send(:[], 0)
      end

      def run
        line_one + line_two + line_three  
      end

      private 

      attr_reader :method_call, :body, :spacing, :argument, :line

      def method_call
        line.split('').each_with_object('') do |character, new_line|
          return new_line if character == '{'

          new_line << character
        end
      end

      def new_body
        body
          .gsub('{', 'do')
          .gsub(/\|\w+(,\w+)*\|/) { |match| "#{match}\n#{spacing}" }
          .gsub('}', )
      end

      def line_one
        method_call.gsub(/\s*\z/, '') + " do#{argument ? ' ' + argument : ''}\n"
      end

      def line_two
        spacing +
        '  ' +
        body.gsub(/\A{\s*(\|\w+(,\w+)*\|)*\s*/, '').gsub(/\s*}\s*\z/, '') +
        "\n"
      end

      def line_three
        spacing + body.match(/}\s*/)[0].gsub('}', 'end')
      end
    end
  end
end
