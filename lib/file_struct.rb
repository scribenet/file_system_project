class FileStruct
  attr_accessor :basename, :content, :path
  attr_reader :ext, :version

  def initialize(path, options = {})
    @path = path
    @basename = File.basename(path)
    @ext = File.extname(path)
    @content = options[:content] || File.read(@path)
    @version = options[:version]
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

