require 'dev_scripts/support/block_expander'

RSpec.describe DevScripts::Support::BlockExpander do
  describe 'self' do
    subject { described_class.new(line: line) }

    context 'when there is a block argument' do
      let(:line) do
        "  things.all.each { |thing| do_something(thing, thing2) }\n"
      end

      let(:expected_block) do
        <<-RUBY
  things.all.each do |thing|
    do_something(thing, thing2)
  end
        RUBY
      end

      it { is_expected.to eq expected_block }
    end

    context 'when there is no block argument' do
      let(:line) do
        "  let(:thing) { do_something(thing) }\n"
      end

      let(:expected_block) do
        <<-RUBY
  let(:thing) do
    do_something(thing)
  end
        RUBY
      end

      it { is_expected.to eq expected_block }
    end
  end
end