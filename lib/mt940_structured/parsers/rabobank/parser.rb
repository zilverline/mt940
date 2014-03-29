module MT940Structured::Parsers::Rabobank
  class Parser < MT940Structured::Parsers::Base
    def initialize
      super "Rabobank", TransactionParsers.new
    end
  end

  class TransactionParsers
    def for_format(is_structured)
      is_structured ? StructuredTransactionParser.new : TransactionParser.new
    end
  end
end
