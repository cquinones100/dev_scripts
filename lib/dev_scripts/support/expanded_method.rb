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

        self << "\n"
      end

      private

      attr_reader :receiver, :method_name, :args, :type, :children

      def string_receiver
        return method_name.to_s if receiver.nil?

        "#{receiver.children[-1].to_s}.#{method_name}"
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
          when :hash
            arg.children.each_with_object('').with_index do |(arg_child, string), index|
              string << INDENT if index > 0

              string << string_arg(arg_child)
              string << "," if index < arg.children.size - 1
              string << "\n" if index < arg.children.size - 1
            end
          when :pair
            "#{arg.children[0].children[0]}: #{string_arg(arg.children[1])}"
          when :nil
            "nil"
          when :int
            "#{arg.children[0]}"
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