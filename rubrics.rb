  RUBRICS = {
    "2" => {
      "HalfAdder" => {:functionality => 6, :quality => 3, :optimal_part_count => 2},
      "FullAdder" => {:functionality => 8, :quality => 4, :optimal_part_count => 3},
      "Add16" => {:functionality => 8, :quality => 4, :optimal_part_count => 16},
      "Inc16" => {:functionality => 10, :quality => 5, :optimal_part_count => 1},
      "ALU" => {:functionality => 35, :quality => 17, :optimal_part_count => 13},
    },
    "3" => {
      "Bit" => {:functionality => 7, :quality => 3},
      "Register" => {:functionality => 7, :quality => 3},
      "RAM8" => {:functionality => 13, :quality => 6},
      "RAM64" => {:functionality => 13, :quality => 6},
      "RAM512" => {:functionality => 5, :quality => 3},
      "RAM4K" => {:functionality => 5, :quality => 3},
      "RAM16K" => {:functionality => 5, :quality => 3},
      "PC" => {:functionality => 12, :quality => 6},
    },
    "5" => {
      "Memory" => {:functionality => 17, :quality => 8, :optimal_part_count => 5},
      "CPU" => {:functionality => 35, :quality => 18, :optimal_part_count => 19},
      "Computer" => {:functionality => 15, :quality => 7, :optimal_part_count => 3},
    },
  }

FEEDBACK_TEMPLATES = {
  "2" => <<~proj2
        Intro to Computer Systems :: Project 2 :: Combinational Chips

        Grading method: The implementation of some chips was described in the
        book, and some chips are simpler than others. The different weights
        assigned to the chips below reflect this variance.  If the chip passes
        all the tests specified in the supplied test script, it receives two
        thirds of its allotted points. The remaining third reflects our
        evaluation of the way the chip is built (we generally prefer
        implementations that use as few parts as possible, since additional
        parts can tax performance and be cost-ineffective).

        Chip                Working?            Well built?         Comments
  proj2
}
