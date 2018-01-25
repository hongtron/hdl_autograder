class Extractor
  def initialize(directory)
    @dir = Dir.new(File.expand_path(directory))
    @submissions = Dir.glob(File.join(@dir.path,"*"))
  end

  def extract_all!
    @submissions.each do |submission|
      unzip(submission) if submission.split(".").last == "zip"
    end
  end

  def student_name(file)
    /project_3_submissions\/([a-z]+)_/.match(file).captures.first
  end

  def destination(file)
    "#{@dir.path}/#{student_name(file)}".gsub(/ /, '\ ')
  end

  def unzip(file)
    %x[unzip #{file.gsub(/ /, '\ ')} -d #{destination(file)}]
  end
end

Extractor.new(ARGV[0]).extract_all!
