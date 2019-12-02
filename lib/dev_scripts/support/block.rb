module DevScripts
  module Support
    class Block < String
      def initialize(args_node, block_node)
        @block_node = block_node

        self << 'do'

        if args_node.children.size > 0
          self << args_node.children.each_with_object(' |').with_index do |(arg, string), index|
            string << arg.children.first.to_s

            string << ', ' if index < args_node.children.size - 1
            string << '|' if index == args_node.children.size - 1
          end
        end

        self << "\n"
        self << '  ' + body
        self << "\n"
        self << 'end'
      end

      private

      attr_reader :block_node

      def args(node)
        node.children.each_with_object(' |').with_index do |(arg, string), index|
          string << arg.children.first.to_s

          string << ', ' if index < node.children.size - 1
          string << "|" if index == node.children.size - 1
        end
      end

      def block_node_method_call?
        block_node.type == :send
      end

      def body
        if block_node_method_call?
          MethodCall.new(block_node)
        else
          if Symbol === block_node.children.first
            ":#{block_node.children.first}"
          else
            block_node.children.first.to_s
          end
        end
      end
    end
  end
end
