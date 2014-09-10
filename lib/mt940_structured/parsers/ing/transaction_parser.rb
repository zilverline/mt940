module MT940Structured::Parsers::Ing
  class TransactionParser
    include MT940Structured::Parsers::DateParser
    include MT940Structured::Parsers::IbanSupport
    include MT940Structured::Parsers::StructuredDescriptionParser
    include MT940Structured::Parsers::Ing::Types

    def parse_transaction(line_61)
      if line_61.match(/^:61:(\d{6})(?:\d{4})?(C|D)(\d+),(\d{0,2})N(\S+)/)
        sign = $2 == 'D' ? -1 : 1
        transaction = MT940::Transaction.new(:amount => sign * ($3 + '.' + $4).to_f)
        transaction.type = human_readable_type($5.strip)
        transaction.date = parse_date($1)
        transaction
      end
    end


    def enrich_transaction(transaction, line_86)
      if line_86.match(/^:86:\s?(.*)\Z/m)
        description = $1.gsub(/>\d{2}/, '').strip
        if description.match(/([P|\d]\d{9})?(.+)/)
          transaction.description = $2.strip
          transaction.contra_account = $1.nil? ? "NONREF" : $1.gsub(/\D/, '').gsub(/^0+/, '')
        else
          transaction.description = description
        end
      end
    end
  end
end
