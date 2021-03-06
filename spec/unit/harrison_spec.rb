require 'spec_helper'

describe Harrison do
  before(:all) do
    [ :@@args, :@@task_runners, :@@config, :@@runner ].each do |class_var|
      Harrison.class_variable_set(class_var, nil)
    end
  end

  after(:each) do
    [ :@@args, :@@task_runners, :@@config, :@@runner ].each do |class_var|
      Harrison.class_variable_set(class_var, nil)
    end
  end

  describe '.invoke' do
    it 'should exit when no args are passed' do
      output = capture(:stderr) do
        expect(lambda { Harrison.invoke([]) }).to exit_with_code(1)
      end

      expect(output).to include('no', 'command', 'given')
    end

    it 'should output base help when first arg is --help' do
      output = capture(:stdout) do
        expect(lambda { Harrison.invoke(['--help']) }).to exit_with_code(0)
      end

      expect(output).to include('options', 'debug', 'help')
    end

    it 'should look for a Harrisonfile' do
      expect(Harrison).to receive(:find_harrisonfile).and_return(harrisonfile_fixture_path)

      output = capture(:stderr) do
        expect(lambda { Harrison.invoke(['test']) }).to exit_with_code(1)
      end

      expect(output).to include('unrecognized', 'command', 'test')
    end

    it 'should complain if unable to find a Harrisonfile' do
      expect(Harrison).to receive(:find_harrisonfile).and_return(nil)

      output = capture(:stderr) do
        expect(lambda { Harrison.invoke(['test']) }).to exit_with_code(1)
      end

      expect(output).to include('could', 'not', 'find', 'harrisonfile')
    end
  end

  describe '.config' do
    it 'should return a new Harrison::Config' do
      mock_config = double(:config)
      expect(Harrison::Config).to receive(:new).and_return(mock_config)

      expect(Harrison.config).to be mock_config
    end

    it 'should return existing Harrison::Config if defined' do
      mock_config = double(:config)
      Harrison.class_variable_set(:@@config, mock_config)
      expect(Harrison::Config).to_not receive(:new)

      expect(Harrison.config).to be mock_config
    end

    it 'should yield config if given a block' do
      mock_config = double(:config)
      Harrison.class_variable_set(:@@config, mock_config)

      expect { |b| Harrison.config(&b) }.to yield_with_args(mock_config)
    end
  end

  describe '.package' do
    before(:each) do
      Harrison.class_variable_set(:@@args, ['package'])
      Harrison.class_variable_set(:@@runner, lambda { Harrison.class_variable_get(:@@task_runners)[:package] if Harrison.class_variable_defined?(:@@task_runners) && Harrison.class_variable_get(:@@task_runners).has_key?(:package) })
    end

    it 'should yield a new Harrison::Package' do
      mock_package = double(:package, parse: true)
      Harrison.class_variable_set(:@@task_runners, Hash.new)

      expect(Harrison::Package).to receive(:new).and_return(mock_package)
      expect { |b| Harrison.package(&b) }.to yield_with_args(mock_package)
    end

    it 'should yield existing Harrison::Package if defined' do
      mock_package = double(:package, parse: true)
      Harrison.class_variable_set(:@@task_runners, { package: mock_package })

      expect(Harrison::Package).to_not receive(:new)
      expect { |b| Harrison.package(&b) }.to yield_with_args(mock_package)
    end
  end

  describe '.deploy' do
    before(:each) do
      Harrison.class_variable_set(:@@args, ['deploy'])
      Harrison.class_variable_set(:@@runner, lambda { Harrison.class_variable_get(:@@task_runners)[:deploy] if Harrison.class_variable_defined?(:@@task_runners) && Harrison.class_variable_get(:@@task_runners).has_key?(:deploy) })
    end

    it 'should yield a new Harrison::Deploy' do
      mock_deploy = double(:deploy, parse: true)
      Harrison.class_variable_set(:@@task_runners, Hash.new)

      expect(Harrison::Deploy).to receive(:new).and_return(mock_deploy)
      expect { |b| Harrison.deploy(&b) }.to yield_with_args(mock_deploy)
    end

    it 'should yield existing Harrison::Deploy if defined' do
      mock_deploy = double(:deploy, parse: true)
      Harrison.class_variable_set(:@@task_runners, { deploy: mock_deploy })

      expect(Harrison::Deploy).to_not receive(:new)
      expect { |b| Harrison.deploy(&b) }.to yield_with_args(mock_deploy)
    end
  end

  context 'private methods' do
    describe '.find_harrisonfile' do
      it 'should find a Harrisonfile if it exists in pwd' do
        expect(Dir).to receive(:pwd).and_return(fixture_path)

        expect(Harrison.send(:find_harrisonfile)).to eq(harrisonfile_fixture_path)
      end

      it 'should find a Harrisonfile if it exists in parent of pwd' do
        expect(Dir).to receive(:pwd).and_return(fixture_path + '/nested')

        expect(Harrison.send(:find_harrisonfile)).to eq(harrisonfile_fixture_path)
      end

      it 'should return nil if there is no Harrisonfile in tree' do
        expect(Dir).to receive(:pwd).and_return(File.dirname(__FILE__))

        # Short circuit upward directory traversal.
        allow(File).to receive(:expand_path).and_call_original
        allow(File).to receive(:expand_path).with("..", File.dirname(__FILE__)).and_return(File.dirname(__FILE__))

        expect(Harrison.send(:find_harrisonfile)).to be_nil
      end
    end

    describe '.eval_script' do
      it 'should eval given script' do
        output = capture(:stdout) do
          Harrison.send(:eval_script, fixture_path + '/eval_script.rb')
        end

        expect(output).to eq("this file was eval-led\n")
      end
    end
  end
end
