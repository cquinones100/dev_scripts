require 'dev_scripts/script'
require 'dev_scripts/support/expanded_block'

DevScripts::Script.define_script :expand_block do
  args :file_path, :line_number

  execute do
    lines = []

    File.foreach(file_path).with_index do |file_line, index|
      if index + 1 == line_number.to_i
        lines << DevScripts::Support::ExpandedBlock.new(line: file_line)
      else
        lines << file_line
      end
    end

    File.open(file_path, 'w') { |file| file.write(lines.join('')) }
  end
end
