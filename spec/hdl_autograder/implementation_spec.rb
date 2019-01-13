require 'spec_helper'
require 'tempfile'

describe HdlAutograder::Implementation do
  it "handles newline characters not paired with carriage returns" do
    chips = %w[And Xor]
    file_contents = <<~CHIP
    CHIP HalfAdder {\r\n
      IN a, b;\r\n
      OUT sum,\r\n
      carry;  \n\r\n
      PARTS:\r\n\n
      And(a = a, b = b, out = carry);\nXor( a = a, b = b, out = sum1);\n\r\n
      }
    CHIP

    Tempfile.open do |t|
      t.sync = true
      t.write file_contents
      i = HdlAutograder::Implementation.new(t, :chip)
      parts_used = i.number_of_parts_used(chips)
      expect(parts_used).to eq(2)
    end
  end
end
