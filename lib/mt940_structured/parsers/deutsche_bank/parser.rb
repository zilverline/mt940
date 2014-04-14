module MT940Structured::Parsers::DeutscheBank
  class Parser < MT940Structured::Parsers::Base
    def initialize
      super "Deutsche Bank", TransactionParsers.new
    end
  end

  class TransactionParsers
    def for_format(_)
      TransactionParser.new
    end
  end

end
