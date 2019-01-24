module HdlAutograder
  class Chip
    def initialize(config)
      @config = config
    end

    def name
      @config["name"]
    end

    def acceptable_part_count
      @config["acceptable_part_count"]
    end

    def exceptional_part_count
      @config["exceptional_part_count"]
    end

    def functionality_points
      @config["points"]["functionality"]
    end

    def quality_points
      @config["points"]["quality"]
    end

    def tests
      @config["tests"] || [name]
    end
  end
end
