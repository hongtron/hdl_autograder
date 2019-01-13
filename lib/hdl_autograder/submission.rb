module HdlAutograder
  class Submission
    attr_accessor :project

    def initialize(project, archive)
      @archive = File.new(archive)
      @project = project
    end

    def ext
      File.extname(@archive)
    end

    def supported_ext?
      [".zip", ".gz", ".tar"].include?(ext)
    end

    def extract!
      case ext
      when ".zip"
        %x[unzip "#{@archive.path}" -d "#{extracted_location}"]
      when ".gz"
        _untar(gzipped: true)
      when ".tar"
        _untar(gzipped: false)
      else
        raise "unhandled ext: #{ext}"
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
        .reject { |f| File.read(f).include?("BUILTIN") }
    end

    def implementations
      @implementations ||= @project.chips.map do |chip|
        hdl_file = hdl_files.find { |f| f.match(/\/#{chip.name}.hdl/) }
        Implementation.new(hdl_file, chip)
      end
    end

    def total_points
      [
      implementations.map(&:functionality_points).select { |x| x.instance_of?(Integer) },
      implementations.map(&:quality_points).select { |x| x.instance_of?(Integer) },
      ].flatten.reduce(:+)
    end

    def feedback
      (
        [] <<
        FEEDBACK_TEMPLATES[@project.project_number] <<
        implementations.map(&:feedback) <<
        "Total points: #{total_points}"
      ).join("\n")
    end
  end
end

