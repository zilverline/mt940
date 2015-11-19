module MT940Structured::Parsers::Generic
  class Parser < MT940Structured::Parsers::Base
    def initialize
      super "Generic", TransactionParsers.new
    end
  end

  class TransactionParsers
    def for_format(_)
      TransactionParser.new
    end
  end

end
