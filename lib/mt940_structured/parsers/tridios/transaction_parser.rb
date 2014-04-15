module MT940Structured::Parsers::Triodos
  class TransactionParser
    include MT940Structured::Parsers::DateParser
    include MT940Structured::Parsers::DefaultLine61Parser

    def get_regex_for_line_61
      /^:61:(\d{6})(\d{4})?(C|D)(\d+),(\d{0,2})/
    end

    def enrich_transaction(transaction, line_86)
      if line_86.match(/^:86:\s?(.*)\Z/m)
        temp_description = $1.gsub(/\n/, ' ').gsub(/>\d{2}/, '').strip
        if temp_description.match(/^\d+(\d{9})(.*)$/)
          transaction.contra_account = $1.rjust(9, '000000000')
          transaction.description = $2.strip
        else
          transaction.description = temp_description
        end
      end

    end
  end
end
