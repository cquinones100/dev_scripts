require 'dev_scripts/script'
require 'dev_scripts/support/expanded_method'
require 'parser/current'

DevScripts::Script.define_script :expand_method_args do
  args :file_path, :line_number
  
  execute do
    lines = []

    File.foreach(file_path).with_index do |file_line, index|
      if index + 1 == line_number.to_i
        lines << DevScripts::Support::ExpandedMethod.new(
          ast_node: Parser::CurrentRuby.parse(file_line)
        )
      else
        lines << file_line
      end
    end

    File.open(file_path, 'w') { |file| file.write(lines.join('')) }
  end
end