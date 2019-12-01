RSpec.describe DevScripts::Script do
  before(:each) { described_class.clear_scripts }

  describe '.execute' do
    context 'when a script name is passsed in' do
      let(:script_name) { :do_something }

      context 'when the script name is registered' do
        let(:script_double) do
          instance_double(described_class, run: nil, name: script_name, duplicate: nil)
        end

        it 'runs the script' do
          allow(described_class).to receive(:new).and_return(script_double)

          DevScripts::Script.define_script script_name do
          end

          expect(script_double).to receive(:run)

          described_class.execute([script_name.to_s])
        end

        it 'deletes the script and replaces with a new copy' do
          DevScripts::Script.define_script script_name do
          end

          expect{ described_class.execute([script_name.to_s]) }
            .to change { described_class.scripts.first }
        end
      end

      context 'when the script name is not registered' do
        it do
          expect { described_class.execute([script_name.to_s]) }
            .to raise_error described_class::ScriptNotRegistered
        end
      end
    end
  end
end
