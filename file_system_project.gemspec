spec = Gem::Specification.new do |s| 
  s.name = 'file_system_project'
  s.version = '0.0.1'
  s.author = 'Dan Corrigan'
  s.email = 'dcorrigan@scribenet.com'
  s.homepage = 'http://wfdm.scribenet.com'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Make a file system project object with accessor methods.'
  s.require_paths << 'lib'
  s.files = Dir.glob("{lib,etc}/**/*")
  s.add_development_dependency('rake')
  s.add_development_dependency('pry')
  s.add_development_dependency('minitest', '> 5.0.0')
  s.add_runtime_dependency('nokogiri')
end
