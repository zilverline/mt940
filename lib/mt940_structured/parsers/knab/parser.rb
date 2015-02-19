module MT940Structured::Parsers::Knab
  class Parser < MT940Structured::Parsers::Base
    def initialize
      super "Knab", TransactionParsers.new
    end
  end

  class TransactionParsers

    def for_format(_)
      TransactionParser.new
    end
  end

end
