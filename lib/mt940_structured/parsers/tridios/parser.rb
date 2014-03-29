module MT940Structured::Parsers::Triodos
  class Parser < MT940Structured::Parsers::Base
    def initialize
      super "Triodos", TransactionParsers.new
    end
  end

  class TransactionParsers
    def for_format(_)
      TransactionParser.new
    end
  end

end
