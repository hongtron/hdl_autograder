module HdlAutograder
  class Grader
    def self.grade(project, submission)
      puts "Grading #{submission.student_name}..."
      test_results = {}
      total_points = 0
      feedback = [] << FEEDBACK_TEMPLATES[project_number]
      implementations = submission.implementations(project.chips)

      HdlAutograder::Simulator.run(project, implementations).each do |chip, outputs|
        all_tests_passed = outputs.map { |o| o =~ /End of script - Comparison ended successfully/ }.all?
        test_results[chip] = all_tests_passed
      end


      project.chips.each do |chip|
        # does this actually work, or does it need to be the chip name?
        implementation = implementations.select { |i| i.chip == chip }

        if implementation && test_results[chip]
          functionality_points = chip.functionality_points
          # move some logic into Implementation
          quality_points = implementation.quality_points(project.builtins)
          num_parts_used = implementation.number_of_parts_used(project.builtins)
          comments = "#{num_parts_used} parts used; #{chip.optimal_part_count} is optimal"
          total_points += functionality_points + quality_points
        elsif implementation
          functionality_points, quality_points = "_"
          comments = "does not pass all tests"
        else
          functionality_points, quality_points = 0
          comments = "not implemented"
        end

        functionality_score = "#{functionality_points}/#{chip.functionality_points}"
        quality_score = "#{quality_points}/#{chip.quality_points}"

        feedback << [
          chip.name,
          functionality_score,
          quality_score,
          comments,
        ].map { |x| x.ljust(20) }.join
      end

      feedback << "Total points: #{total_points}"
      feedback = feedback.join("\n")

      write_feedback(submission, feedback)
    end

    def self.write_feedback(submission, feedback)
      feedback_file = File.join(submission.extracted_location, "#{submission.student_name}_feedback.txt")
      File.open(feedback_file, 'w') { |f| f.write(feedback) }
    end
  end
end

