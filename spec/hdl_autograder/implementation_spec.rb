require 'spec_helper'
require 'tempfile'

describe HdlAutograder::Implementation do
  it "handles newline characters not paired with carriage returns, and vice versa" do
    chips = %w[And Xor]
    file_contents = <<~CHIP
    CHIP Something {\r\n
      IN a, b;\r\n
      OUT sum2,\r\n
      carry;  \n\r\n
      PARTS:\r\n\n
      And(a = a, b = b, out = carry);\nXor( a = a, b = b, out = sum1);\rXor( a = a, b = b, out = sum2);\n\r\n
      }
    CHIP

    Tempfile.open do |t|
      t.sync = true
      t.write file_contents
      i = HdlAutograder::Implementation.new(t, :chip)
      parts_used = i.number_of_parts_used(chips)
      expect(parts_used).to eq(3)
    end
  end
end
