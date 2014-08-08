require_relative 'test_helper'

describe FileSystemProject do

  YAM = {
    :dirs => {
      'indd' => {
        :type => 'xml'
      },
      'sam' => {
        :type => 'xml'
      },
      'docx' => {
        :type => 'bin'
      },
    }
  }
  before do
    @tempdir = Dir.mktmpdir 'random'
    @path = File.absolute_path @tempdir
    FileUtils.rm_r( @path ) if File.exists? @path
    FileUtils.cp_r File.absolute_path("#{__FILE__}/../samples/project_dir"), @path
    @project = FileSystemProject.new(@path, YAM)
  end

  describe 'when asked for a set of files' do
    describe 'when there are files that match the requested type' do
      it 'returns a collection with all of the requested files' do
        expected_docx = Dir[@path + "/docx/*"].sort.map {|e| File.absolute_path e }
        @project.docx_files.map{|x| x.path}.sort.must_equal expected_docx
        expected_sam = Dir[@path + "/sam/*"].sort.map {|e| File.absolute_path e }
        @project.sam_files.map{|x| x.path}.sort.must_equal expected_sam
      end
    end

    describe 'when there are no files that match the requested type' do
      it 'returns an empty collect' do
        assert_equal 0, @project.indd_files.count
      end
    end
  end

  describe 'when adding a new file' do
    before do
      @text ="<sam><pf>short and sweet</pf></sam>"
      @project.add_sam_file(@text, name: 'foo.sam')
    end
    it "writes the text to the file type's subdir" do
      File.read(@path + "/sam/foo.sam").must_equal @text
    end

    it 'adds the file to the collection' do
      @project.sam_files.map{|x| x.path}.select { |e| e =~ /foo\.sam/ }.count.must_equal 1
    end
  end
end
