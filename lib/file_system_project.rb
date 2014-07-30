require 'nokogiri'

class FileStruct
  attr_accessor :basename, :content, :path
  attr_reader :ext

  def initialize(path, options = {})
    @path = path
    @basename = File.basename(path)
    @ext = File.extname(path)
    @content = File.read(@path)
  end

  def basic_name
    File.basename(@path, @ext)
  end

  def content
    @content ||= File.read(@path)
  end

  def reload!
    @content = File.read(@path)
  end

  def save!
  end
end

class XMLFileStruct < FileStruct
  def doc
    @doc ||= Nokogiri.XML(@content)
  end

  def reload!
    super
    @doc = Nokogiri.XML(@content)
  end

  def save!
    @content = @doc.to_xml(encoding: 'UTF-8', indent: 2)
  end

  def content
    @content ||= @doc.to_xml(encoding: 'UTF-8', indent: 2)
  end
end

class YAMLFileStruct < FileStruct
  def doc
    @doc ||= YAML.load(@content)
  end

  def reload!
    super
    @doc = YAML.load(@content)
  end

  def save!
    @content = @doc.to_yaml
  end

  def content
    @content ||= @doc.to_yaml
  end
end

class FileSystemProject
  attr_reader :root, :file_system

  def initialize(project_dir, file_system)
    @root = project_dir
    @file_system = file_system
  end

  def method_missing(method, *args)
    if method.match(/^.+_files/)
      get_files(method)
    else
      super
    end
  end

  def known_directory(method)
    @file_system[:dirs].keys.find { |d| method.match(/#{d}_files/) }
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

  def get_files(method)
    dir = known_directory(method)
    fail "Unknown directory." if dir.nil?
    type = @file_system[:dirs][dir]
    locations = Dir.glob(File.join(@root, dir, '/*'))
    locations.map{ |d| file_struct(type).new(d) }
  end
end
