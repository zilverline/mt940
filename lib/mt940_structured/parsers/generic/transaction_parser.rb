module MT940Structured::Parsers::Generic
  class TransactionParser
    include MT940Structured::Parsers::DateParser
    include MT940Structured::Parsers::DefaultLine61Parser
    include MT940Structured::Parsers::IbanSupport

    def get_regex_for_line_61
      /^:61:(\d{6})(\d{4})?(C|D)\S?(\d+),(\d{0,2})/
    end

   
  def parse_line_25(line)
     puts "In generic method for 25. #{line}"
     line.gsub!('.', '')
     @bank_statement.bank_account = line.gsub(/\D/, '').gsub(/^0+/, '')
  end
      
    def enrich_transaction(transaction, line_86)
      if line_86.match(/^:86:(.*)$/)
        transaction.description = [transaction.description, $1].join(" ").strip
      end
    end
  end
end
