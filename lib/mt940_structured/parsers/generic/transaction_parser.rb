module MT940Structured::Parsers::Generic
  class TransactionParser
    include MT940Structured::Parsers::DateParser
    include MT940Structured::Parsers::DefaultLine61Parser
    include MT940Structured::Parsers::IbanSupport

    def get_regex_for_line_61
      /^:61:(\d{6})(\d{4})?(C|D|DD|CD|RC|RD|CR|DR)(\d+),(\d{0,2})N(.{3})([a-zA-Z\d\s?]{1,16})(\/?\/?[a-zA-Z\d\s?]{1,16})?/
    end

    def parse_transaction(line_61)
      if line_61.match(get_regex_for_line_61)
        #puts "$3 -- #{$3}"
        type = $3 == 'D' ? -1 : ($3 == 'RC' ? -1 : 1)
        transaction = MT940::Transaction.new(amount: type * ($4 + '.' + $5).to_f)
        transaction.customer_reference = $7
        transaction.bank_reference = $8
        transaction.date = parse_date($1)
        transaction.date_accounting = $2 ? parse_date($1[0..1] + $2) : transaction.date
        transaction.type = $3
        transaction
      end
    end

    def parse_line_25(line)
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
