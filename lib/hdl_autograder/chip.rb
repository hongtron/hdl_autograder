module HdlAutograder
  class Chip
    def initialize(config)
      @name = config[:name]
      @functionality_points = config[:points][:functionality]
      @quality_points = config[:points][:functionality]
      @tests = config[:tests] || ["#{@name}.tst"]
    end
  end
end
