module MT940Structured::Parsers::Sns
  class Parser < MT940Structured::Parsers::Base
    def initialize
      super "Sns", TransactionParsers.new
    end
  end

  class TransactionParsers

    def for_format(_)
      TransactionParser.new
    end
  end

end
