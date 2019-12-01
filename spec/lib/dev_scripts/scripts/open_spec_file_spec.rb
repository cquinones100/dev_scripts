RSpec.describe :open_spec_file do
  load_file "dev_scripts/scripts/#{described_class}"

  let(:file_name) { 'something.rb' }
  let(:spec_file_name) { 'spec/something_spec.rb' }

  after(:all) do
    File.delete('spec/something_spec.rb') if File.exist?('spec/something_spec.rb')
  end

  describe 'creating and reading files' do
    before do
      allow_any_instance_of(DevScripts::Script).to receive(:create_file_in_editor)
      allow_any_instance_of(DevScripts::Script).to receive(:open_file_in_editor)
    end

    context "when the spec file doesn't already exist" do
      before do
        File.delete(spec_file_name) if File.exist?(spec_file_name)
      end

      it 'creates the file' do
        expect_any_instance_of(DevScripts::Script)
          .to receive(:create_file_in_editor)
          .with(spec_file_name)

        DevScripts::Script.execute([described_class, file_name])
      end

      it 'opens the file' do
        expect_any_instance_of(DevScripts::Script)
          .to receive(:create_file_in_editor)
          .with(spec_file_name)

        DevScripts::Script.execute([described_class, file_name])
      end
    end

    context 'when the spec file already exists' do
      before { File.open(spec_file_name, 'w') }

      it 'does not creates the file' do
        expect_any_instance_of(DevScripts::Script)
          .to_not receive(:create_file_in_editor)
          .with(spec_file_name)

        DevScripts::Script.execute([described_class, file_name])
      end
    end

    context 'when already in a spec file' do
      it do
        expect_any_instance_of(DevScripts::Script)
          .to receive(:print_message)
          .with(ALREADY_IN_SPEC_FILE_MESSAGE)

        DevScripts::Script.execute([described_class, spec_file_name])
      end
    end
  end

  describe 'file content' do
    before do
      File.delete(spec_file_name) if File.exist?(spec_file_name)

      allow_any_instance_of(DevScripts::Script).to receive(:open_file_in_editor)

      DevScripts::Script.execute([described_class, file_name])
    end

    subject { File.read("./#{spec_file_name}") }

    it { is_expected.to eq "RSpec.describe Something do\nend\n" }
  end
end
