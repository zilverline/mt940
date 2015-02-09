module MT940Structured::Parsers::VanLanschot
  class Parser < MT940Structured::Parsers::Base
    def initialize
      super "van Lanschot", TransactionParsers.new
    end
  end

  class TransactionParsers

    def for_format(_)
      TransactionParser.new
    end
  end

end
