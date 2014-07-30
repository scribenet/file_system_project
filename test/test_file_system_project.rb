require_relative '../lib/file_system_project'
require 'minitest'
require 'minitest/autorun'
require 'yaml'

module TestHelpers
  SAMPLES = File.join(File.dirname(__FILE__), 'samples')

  def sample_dir(name)
    File.join(SAMPLES, name)
  end

  def sample_yaml(name)
    file = Dir.glob(File.join(sample_dir(name), '/*.yml')).first
    YAML.load(File.read(file))
  end

  def sample_project(name)
    main = sample_dir(name)
    Dir.glob(File.join(main, '/*')).find { |x| File.directory?(x) }
  end

  def yaml_and_dir(name)
    [sample_yaml(name), sample_project(name)]
  end
end

class PrintArticulationTests < Minitest::Test
  include TestHelpers

  def setup
    @fs = FileS
  end

  def test_basic
    @yaml, @project = yaml_and_dir('file_system1')


  end
end
