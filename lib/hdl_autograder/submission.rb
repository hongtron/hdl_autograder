module HdlAutograder
  class Submission
    def initialize(archive)
      @archive = File.new(archive)
    end

    def extract!
      ext = File.extname(@archive)
      case ext
      when ".zip"
        %x[unzip "#{@archive.path}" -d "#{extracted_location}"]
      when ".gz"
        _untar(gzipped: true)
      when ".tar"
        _untar(gzipped: false)
      else
        puts "unhandled ext: #{ext}"
      end
    end

    def _untar(gzipped: true)
      Dir.mkdir(extracted_location)
      params = gzipped ? "xzf" : "xf"
      %x[tar -#{params} "#{@archive.path}" -C "#{extracted_location}"]
    end

    def extracted_location
      File.join(File.dirname(@archive), student_name)
    end

    def student_name
      /extracted\/([a-z]+)_/.match(@archive.path).captures.first
    end

    def hdl_files
      Dir.glob(File.join(extracted_location, "**/*.hdl"))
    end
  end
end

