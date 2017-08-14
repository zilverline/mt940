module MT940Structured::Parsers::Nedbank
  class TransactionParser
    include MT940Structured::Parsers::DateParser
    include MT940Structured::Parsers::IbanSupport
    include MT940Structured::Parsers::StructuredDescriptionParser
    include MT940Structured::Parsers::DefaultLine61Parser

    def parse_transaction(line_61)
      # if line_61.match(/^:61:(\d{6})(?:\d{4})?(C|D)\s(\d+),(\d{0,2})N(.{3})([^\s?]{1,16})(\-?.{1,16})?/)
      if line_61.match(/^:61:(\d{6})(?:\d{4})?(C|D)\s(\d+),(\d{0,2})N(.{3})(.*$)?/)
        sign = $2 == 'D' ? -1 : 1
        transaction = MT940::Transaction.new(:amount => sign * ($3 + '.' + $4).to_f)
        transaction.type = $2
        transaction.customer_reference = $6
        transaction.bank_reference = $7
        transaction.description = $6
        transaction.date = parse_date($1)
        transaction
      end
    end

  end
end
