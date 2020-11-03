module MT940Structured::Parsers::Rabobank
  class TransactionParser
    include MT940Structured::Parsers::DateParser, Types

    def parse_transaction(line_61)
      if line_61.match(/^:61:(\d{6})(C|D)(\d+),(\d{0,2})N(.{3})([P|\d]\d{9}|NONREF)\s*(.+)?$/)
        sign = $2 == 'D' ? -1 : 1
        transaction = MT940::Transaction.new(:amount => sign * ($3 + '.' + $4).to_f)
        transaction.type = human_readable_type($5)
        transaction.date = parse_date($1)
        number = $6.strip
        name = $7 || ""
        number = number.gsub(/\D/, '').gsub(/^0+/, '') unless number == 'NONREF'
        transaction.contra_account = number
        transaction.contra_account_owner = name.strip
        transaction
      else
        raise line_61
      end
    end

    def enrich_transaction(transaction, line_86)
      if line_86.match(/^:86:(.*)/m)
        transaction.description = [transaction.description, $1].join(" ").strip
      end
    end
  end
end
