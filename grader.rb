class Extractor
  def initialize(directory)
    @dir = Dir.new(File.expand_path(directory))
  end

  def submissions
    Dir.glob(File.join(@dir.path,"*"))
  end

  def extract_all!
    submissions.each { |submission| extract_submission(submission) }
  end

  def student_name(file)
    /project_3_submissions\/([a-z]+)_/.match(file).captures.first
  end

  def destination(file)
    "#{@dir.path}/#{student_name(file)}"
  end

  def extract_submission(file)
    ext = File.extname(file)
    case ext
    when ".zip"
      unzip(file)
    when ".gz"
      untar(file, true)
    when ".tar"
      untar(file, false)
    else
      puts "unhandled ext: #{ext}"
    end
  end

  def unzip(file)
    %x[unzip "#{file}" -d "#{destination(file)}"]
  end

  def untar(file, gzipped)
    Dir.mkdir(destination(file))
    params = gzipped ? "xzf" : "xf"
    %x[tar -#{params} "#{file}" -C "#{destination(file)}"]
  end

  def hdl_files(submission_folder)
    Dir.glob(File.join(submission_folder, "**/*.hdl"))
  end

  def submission_folders
    submissions.select { |x| File.directory?(x) }
  end
end

class Grader
  def initialize(extractor)
    @extractor = extractor
    @test_dir = Dir.new("./tests/3")
  end

  def grade(submission_folder)
  end
end

e = Extractor.new(ARGV[0])
g = Grader.new(e)
# e.extract_all!
# puts e.hdl_files(e.submission_folders.first)
