class FileStruct
end

class FileSystem
  def initialize(structure)
  end
end

class FileSystemProject
  attr_reader :root, :file_system

  def initialize(project_dir, file_system)
    @root = project_dir
    @file_system = file_system
  end

  def method_missing(method, *args)
    if file_system.respond_to?(meth)
      file_system.send(method, *args)
    else
      super
    end
  end
end
