module MT940Structured::Parsers::Ing
  class Parser < MT940Structured::Parsers::Base
    def initialize
      super "Ing", TransactionParsers.new
    end
  end

  class TransactionParsers
    def structured?(line_61)
      line_61.match(/EREF|PREF|MARF|TRFNONREF|\d{14}/)
    end

    def for_format(is_structured)
      is_structured ? StructuredTransactionParser.new : TransactionParser.new
    end
  end

end
