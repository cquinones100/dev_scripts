module DevScripts
  class Script
    class ScriptNotRegistered < StandardError
      def initialize(script_name)
        super "#{script_name} not registered"
      end
    end

    class << self
      def scripts
        @scripts ||= []
      end

      def clear_scripts
        @scripts = []
      end

      def define_script(script_name, &block)
        scripts << new(script_name: script_name, &block)
      end

      def execute(args)
        script_name, *rest = args

        script_to_execute = scripts.find { |script| script.name == script_name.to_sym }

        if script_to_execute
          script_to_execute.run(rest) 

          scripts[scripts.index(script_to_execute)] = script_to_execute.duplicate
        else
          raise ScriptNotRegistered.new(script_name)
        end
      end
    end

    attr_reader :name

    def initialize(script_name:, &block)
      @name = script_name
      @block = block
      @base = block.binding.receiver
      @run_args = []
    end

    def run(args)
      @run_args = args

      instance_eval(&block)
    end

    def duplicate
      self.class.new(script_name: name, &block)
    end

    private 

    attr_reader :block, :base, :run_args, :arg_names_to_args, :before_block

    def let(name, &block)
      define_singleton_method(name) do
        found_value = instance_variable_get("@#{name}") 
        return found_value unless found_value.nil?

        instance_variable_set("@#{name}", instance_eval(&block))
      end
    end

    def before(&block)
      @before_block = block
    end

    def execute(&block)
      instance_eval(&before_block) if before_block

      instance_eval(&block)
    end

    def args(*arg_names)
      arg_names.each_with_index do |arg_name, index|
        define_singleton_method(arg_name) do
          found_value = instance_variable_get("@#{arg_name}") 

          return found_value unless found_value.nil?

          instance_variable_set("@#{arg_name}", run_args[index])
        end
      end
    end

    def create_file_in_editor(file_path_to_open, &file_content_block)
      File.open(file_path_to_open, 'w') do |file|
        file.write(instance_eval(&file_content_block))
      end
    rescue Errno::ENOENT
      Dir.mkdir file_path_to_open.split('/')[0..-2].join('/')

      retry
    end

    def open_file_in_editor(file_path_to_open)
      system "code -r #{file_path_to_open}"
    end
  end
end