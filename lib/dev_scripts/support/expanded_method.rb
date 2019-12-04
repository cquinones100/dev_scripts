module DevScripts
  module Support
    class ExpandedMethod < String
      INDENT = '  '.freeze
      class NotAMethodError < StandardError; end

      def initialize(ast_node:)
        @type = ast_node.type
        @children = ast_node.children

        raise NotAMethodError unless [:send, :block].include?(type)

        get_components

        self << string_receiver

        args.each_with_index do |arg, index|
          if index == 0
            self << '('
            self << "\n"
          end
          self << INDENT + string_arg(arg)
          self << "," unless index == args.length - 1
          self << "\n"
          self << ")" if index == args.length - 1
        end

        case type
        when :block
          self << ' do'
          self << "\n"
          self << INDENT + string_block_body
          self << "\n"
          self << 'end'
        end
      end

      private

      attr_reader :receiver, :method_name, :args, :type, :children

      def string_receiver
        return method_name.to_s if receiver.nil?
      end

      def string_arg(arg)
        case arg.type
          when :send
           FlattenedMethod.new(ast_node: arg)
          when :sym
            ":#{arg.children[-1]}"
          when :str
            "'#{arg.children[-1]}'"
          when :block
            FlattenedMethod.new(ast_node: arg)
        end
      end

      def string_block_body
        case children[-1].type
        when :str
          "'#{children[-1].children[-1]}'"
        end
      end

      def get_components
        case type
        when :send
          @receiver, @method_name, *@args = children
        when :block
          @receiver, @method_name, *@args = children.first.children
        end
      end
    end

    class FlattenedMethod < ExpandedMethod
      def initialize(ast_node:)
        @type = ast_node.type
        @children = ast_node.children

        raise NotAMethodError unless [:send, :block].include?(type)

        get_components

        self << string_receiver

        args.each_with_index do |arg, index|
          if index == 0
            self << '('
          end
          self << string_arg(arg)
          self << "," unless index == args.length - 1
          self << ")" if index == args.length - 1
        end

        case type
        when :block
          self << ' { '
          self << string_block_body
          self << ' }'
        end
      end
    end

  end
end