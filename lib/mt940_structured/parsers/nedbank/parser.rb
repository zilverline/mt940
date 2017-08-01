module MT940Structured::Parsers::Nedbank
  class Parser < MT940Structured::Parsers::Base
    def initialize
      super "Nedbank", TransactionParsers.new
    end
  end

  class TransactionParsers

    def for_format(_)
      TransactionParser.new
    end
  end

end
