require 'parser/current'
require 'dev_scripts/support/expanded_method'

RSpec.describe DevScripts::Support::ExpandedMethod do
  subject { described_class.new(ast_node: Parser::CurrentRuby.parse(line)) }

  context 'when the method has no args' do
    let(:line) { "create" }

    it { is_expected.to eq line }
  end

  context 'when the method is the only thing in the line' do
    let(:line) { "create(thing, :thing2, 'thing3')" }
    let(:expected_result) do
      <<-RUBY
create(
  thing,
  :thing2,
  'thing3'
)
      RUBY
    end


    it { is_expected.to eq expected_result.chomp }
  end

  context 'when the method has a block arg' do
    context 'when the block arg is in addition to other args' do
      let(:line) { "create(thing) { 'something' }" }
      let(:expected_result) do
        <<-RUBY
create(
  thing
) do
  'something'
end
        RUBY
      end

      it { is_expected.to eq expected_result.chomp }
    end

    context 'when the block arg is the only arg' do
      let(:line) { "create { 'something' }" }
      let(:expected_result) do
        <<-RUBY
create do
  'something'
end
        RUBY
      end

      it { is_expected.to eq expected_result.chomp }
    end

    context 'when the method has nested methods as args' do
      let(:line) do
        <<~RUBY
          create(thing, thing2, create2(thing3))
        RUBY
      end

      let(:expected_result) do
        <<~RUBY
          create(
            thing,
            thing2,
            create2(thing3)
          )
        RUBY
      end

      it { is_expected.to eq expected_result.chomp }
    end

    context 'when the method has nested blocks as args' do
      let(:line) do
        <<~RUBY
          create(thing, thing2, create2(thing3) { 'something' })
        RUBY
      end

      let(:expected_result) do
        <<~RUBY
          create(
            thing,
            thing2,
            create2(thing3) { 'something' }
          )
        RUBY
      end

      it { is_expected.to eq expected_result.chomp }
    end
  end
end