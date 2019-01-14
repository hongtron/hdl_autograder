module HdlAutograder
  class Submission
    attr_accessor :project

    def initialize(project, source)
      @source = File.new(source)
      @project = project
    end

    def ext
      File.extname(@source)
    end

    def supported_ext?
      [".zip", ".gz", ".tar"].include?(ext)
    end

    def compressed?
      File.file?(@source) && supported_ext?
    end

    def extract!
      return unless compressed?

      case ext
      when ".zip"
        %x[unzip "#{@source.path}" -d "#{extracted_location}"]
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
      %x[tar -#{params} "#{@source.path}" -C "#{extracted_location}"]
    end

    def extracted_location
      File.join(File.dirname(@source), student_name)
    end

    def student_name
      if compressed?
      /extracted\/([a-z]+)_/.match(@source.path).captures.first
      else
        File.basename(@source)
      end
    end

    def hdl_files
      source_dir = compressed? ? extracted_location : @source
      Dir.glob(File.join(source_dir, "**/*.hdl"))
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
        @project.feedback_template <<
        implementations.map(&:feedback) <<
        "Total points: #{total_points}"
      ).join("\n")
    end
  end
end

