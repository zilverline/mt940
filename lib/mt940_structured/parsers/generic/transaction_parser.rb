module MT940Structured::Parsers::Generic
  class TransactionParser
    include MT940Structured::Parsers::DateParser
    include MT940Structured::Parsers::DefaultLine61Parser

    def get_regex_for_line_61
      /^:61:(\d{6})(\d{4})?(C|D)(\d+),(\d{0,2})/
    end

   

      
    def enrich_transaction(transaction, line_86)
		transaction
	end
  end
end
