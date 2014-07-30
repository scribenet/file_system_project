require 'nokogiri'
require_relative 'file_struct'

class FileSystemProject
  attr_reader :root, :file_system

  def initialize(project_dir, file_system)
    @root = project_dir
    @file_system = file_system
  end

  def method_missing(method, *args)
    if dir = directory_accessor(method)
      get_files(dir)
    elsif dir = directory_adder(method)
      add_file(dir, *args)
    else
      super
    end
  end

  def directory_accessor(method_name)
    @file_system[:dirs].keys.find { |d| method_name.match(/^#{d}_files$/) }
  end

  def directory_adder(method_name)
    @file_system[:dirs].keys.find { |d| method_name.match(/^add_#{d}_file$/) }
  end

  def file_struct(type)
    case type
    when 'xml'
      XMLFileStruct
    when 'yaml'
      YAMLFileStruct
    else
      FileStruct
    end
  end

  def dir_path(dir)
    File.join(@root, dir)
  end

  def get_files(dir)
    type = @file_system[:dirs][dir]
    locations = Dir.glob(File.join(dir_path(dir), '/*'))
    locations.map{ |d| file_struct(type).new(d) }
  end

  def add_file(dir, *args)
    fail ArgumentError unless valid_adder_args?(args)
    outdir = File.join(@root, dir)
    ensure_dir_exists(outdir)
    outfile = File.join(outdir, args[0])
    write_and_sync(outfile, args[1])
  end

  def write_and_sync(file, content)
    out = File.open(file, 'w')
    out.write(content)
    out.fsync
  end

  def ensure_dir_exists(dir)
    Dir.mkdir(dir) unless File.exist?(dir)
  end

  def valid_adder_args?(args)
    args.size == 2 and args.all? { |a| a.is_a?(String) }
  end
end
