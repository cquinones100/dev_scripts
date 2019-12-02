module DevScripts
  module Support
    class MethodCall < String
      attr_reader :receiver, :invocation, :args

      def initialize(ast_node)
        current_receiver, @invocation, *@args = ast_node.children

        invocation_stack = [invocation_with_args]

        while Parser::AST::Node === current_receiver
          invocation_stack.unshift MethodCall.new(current_receiver).invocation_with_args

          current_receiver, invocation, *args = current_receiver&.children || []
        end

        invocation_stack.each_with_index do |invocation_string, index|
          self << '.' if index > 0
          self << invocation_string.to_s
        end
      end

      def invocation_with_args
        if args && args.size > 0
          args.each_with_object("#{invocation}(").with_index do |(arg, string), index|
            string << arg_string(arg)

            string << ', ' if index < args.size - 1
            string << ')' if index == args.size - 1
          end
        else
          invocation
        end
      end

      def arg_string(arg)
        case arg.type
        when :sym
          ":#{arg.children[0]}"
        when :str
          "#{arg.children[0]}"
        when :int
          "#{arg.children[0].to_i}"
        when :lvar
          "#{arg.children[0]}"
        when :send
          "#{arg.children[1]}"
        when :hash
          arg_string(arg.children[0])
        when :pair
          key, value = arg.children

          "#{key.children.first}: #{value.children.last}"
        end
      end
    end
  end
end