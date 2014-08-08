require_relative 'test_helper'

class PrintArticulationTests < Minitest::Test
  include TestHelpers

  def setup_project
    @fsproject = FileSystemProject.new(@project, @yaml)
  end

  def teardown
    delete_added_files
  end

  def setup
    delete_added_files
  end

  def delete_added_files
    dels = Dir.glob(File.join(SAMPLES, '/**/*')).collect { |x| x if x.match(/\/new_/) }.compact
    dels.map { |d| File.delete(d) }
  end

  def basic_accessor_assertions
    assert @fsproject.foocatchoo_files.is_a?(Array)
    assert @fsproject.foocatchoo_files.first.content.is_a?(String)
    assert @fsproject.foocatchoo_files.first.ext == '.xml'
    assert @fsproject.foocatchoo_files.first.doc.is_a?(Nokogiri::XML::Document)
    assert @fsproject.socrates_files.is_a?(Array)
    assert @fsproject.socrates_files.first.content.is_a?(String)
    assert @fsproject.socrates_files.first.ext == '.yml'
    assert @fsproject.socrates_files.first.doc.is_a?(Hash)
  end

  def basic_adder_assertions
    current_size = @fsproject.foocatchoo_files.size
    @fsproject.add_foocatchoo_file("<foo/>", name: 'new_foo.xml')
    assert @fsproject.foocatchoo_files.size > current_size
  end

  def test_basic_project
    @yaml, @project = yaml_and_dir('file_system1')
    setup_project
    basic_accessor_assertions
    basic_adder_assertions
    assert @fsproject.option_one
    assert @fsproject.contributors
    assert @fsproject.contributors.contribs
  end
end
