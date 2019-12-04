require 'dev_scripts/script'

class AlreadyInASpecFileError < StandardError
end

ALREADY_IN_SPEC_FILE_MESSAGE = 'Already in Spec File'

DevScripts::Script.define_script :open_spec_file do
  args :file_path 

  def file_exists?
    !found_file_path.nil?
  end

  def already_in_a_spec_file?
    !(file_path =~ /_spec.rb\Z/).nil?
  end

  let(:file_path_without_extension) do
    file_path
      .gsub(/\A\w+\//, '')
      .gsub('.rb', '')
  end

  let(:found_file_path) do
    Dir['./spec/**/*.rb'].find do |path|
      !(path =~ /#{file_path_without_extension}_spec.rb/).nil?
    end
  end

  let(:spec_file_path) do
    if file_exists?
      found_file_path
    else
      "spec/#{file_path_without_extension}_spec.rb"
    end
  end

  let(:constant_name) do
    require 'active_support/inflector'

    spec_file_path
      .gsub(/\Aspec\/|_spec\.rb/, '')
      .split('/')
      .map(&:camelize)
      .join('::')
  end

  execute do
    begin
      raise AlreadyInASpecFileError if already_in_a_spec_file?

    if file_exists?
      print_message 'file already exists, opening file'
    else
      print_message 'file does not exist, writing a new file'

      create_file_in_editor spec_file_path do
        <<-RUBY
RSpec.describe #{constant_name} do
end
        RUBY
      end
    end

    open_file_in_editor spec_file_path

    rescue AlreadyInASpecFileError
      print_message 'Already in Spec File'
    end
  end
end
