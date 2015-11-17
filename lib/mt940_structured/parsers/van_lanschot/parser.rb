module MT940Structured::Parsers::VanLanschot
  class Parser < MT940Structured::Parsers::Base
    def initialize
      super "van Lanschot", TransactionParsers.new, MT940Structured::Parsers::NEXT_LINES_FOR.merge('86' => ['20', '61', '62'])
    end

  end

  class TransactionParsers

    def for_format(_)
      TransactionParser.new
    end
  end

end
