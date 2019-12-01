require 'dev_scripts/script'

DevScripts::Script.define_script :open_spec_file do
  args :file_path 

  def file_exists?
    !found_file_path.nil?
  end

  let(:file_path_without_extension) do
    file_path.gsub('.rb', '')
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
      .gsub(/spec\/|_spec\.rb/, '')
      .split('/')
      .map(&:camelize)
      .join('::')
  end

  execute do
    if file_exists?
      puts 'file already exists, opening file'
    else
      puts 'file does not exist, writing a new file'

      create_file_in_editor spec_file_path do
        <<-RUBY
RSpec.describe #{constant_name} do
end
        RUBY
      end
    end

    open_file_in_editor spec_file_path
  end
end
