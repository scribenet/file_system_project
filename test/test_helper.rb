require 'simplecov'
require 'simplecov-html'
require "coveralls"
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter,
]

SimpleCov.start do
  add_filter 'test/'
end if ENV['COVERAGE']

require 'minitest'
require 'minitest/unit'
require 'minitest/autorun'
require 'tmpdir'
require 'yaml'
require 'file_system_project'

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

