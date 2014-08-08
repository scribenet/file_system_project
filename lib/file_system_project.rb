require 'nokogiri'
require_relative 'file_struct'
require_relative 'data_mapper'

class FileSystemProject
  attr_reader :root, :file_system, :data_map
  attr_accessor :error_log
  alias_method :path, :root

  def initialize(project_dir, file_system)
    @root = project_dir
    fail(ArgumentError, "Project directory does not exist.") unless File.exist?(@root)
    @file_system = file_system
    @data_map = data_file_exists? ? make_data_accessors(file_system) : nil
    add_data_map_methods if @data_map
    @error_log = {}
  end

  def add_to_error_log(name, error)
    error_log[name] = error
  end

  def data_file_exists?
    file_system[:data] and File.exists?(data_file_path)
  end

  def data_file_path
    File.join(root, file_system[:data][:loc], 'data.xml')
  end

  def make_data_accessors(file_system)
    raw_data = File.read(data_file_path)
    DataMapper.new(raw_data)
  end

  def add_data_map_methods
    @data_map.mapper.singleton_methods.each do |meth|
      self.class.send(:define_method, meth) do
        data_map.mapper.send(meth)
      end
    end
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

  def data_has?(method)
    data and data_for(method)
  end

  def data_for(method)
    begin
      data_map.mapper.send(method)
    rescue
      false
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
    when 'txt'
      FileStruct
    when 'bin'
      FileStruct
    else
      FileStruct
    end
  end

  def dir_path(dir)
    File.join(@root, dir)
  end

  def get_files(dir)
    type = @file_system[:dirs][dir][:type]
    locations = Dir.glob(File.join(dir_path(dir), '/**/*')).reject { |d| File.directory?(d) }
    locations.map do |d|
      opts = @file_system[:dirs][dir][:versions] ? {version: get_version(d)} : {}
      file_struct(type).new(d, opts)
    end
  end

  def get_version(f)
    File.dirname(f)[/(?<=\/)[^\/]+$/]
  end

  def add_file(dir, *args)
    fail ArgumentError, "Wrong number or type of file arguments." unless valid_adder_args?(args)
    outdir = File.join(@root, dir)
    ensure_dir_exists(outdir)
    content = args[0]
    options = args[1]
    outfile = File.join(outdir, options[:name])
    write_and_sync(outfile, content)
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
    args.size == 2 and args[1].is_a?(Hash)
  end
end

module ErrorLogging
end
