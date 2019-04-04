module MT940Structured::Parsers::Abnamro
  class Parser < MT940Structured::Parsers::Base
    def initialize(bank_name = "Abnamro")
      super bank_name, TransactionParsers.new
    end
  end

  class TransactionParsers

    def for_format(_)
      TransactionParser.new
    end
  end

end
