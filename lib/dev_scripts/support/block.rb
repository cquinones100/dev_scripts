module DevScripts
  module Support
    class Block < String
      def initialize(args_node, block_node)
        self << 'do'

        if args_node.children.size > 0
          self << args_node.children.each_with_object(' |').with_index do |(arg, string), index|
            string << arg.children.first.to_s

            string << ', ' if index < args_node.children.size - 1
            string << '|' if index == args_node.children.size - 1
          end
        end

        self << "\n"
        self << '  ' + MethodCall.new(block_node)
        self << "\n"
        self << 'end'
      end

      def args(node)
        node.children.each_with_object(' |').with_index do |(arg, string), index|
          string << arg.children.first.to_s

          string << ', ' if index < node.children.size - 1
          string << "|" if index == node.children.size - 1
        end
      end
    end
  end
end
