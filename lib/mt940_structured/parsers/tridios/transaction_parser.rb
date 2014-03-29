module MT940Structured::Parsers::Triodos
  class TransactionParser
    include MT940Structured::Parsers::DateParser

    def parse_transaction(line_61)
      if line_61.match(/^:61:(\d{6})\d{4}(C|D)(\d+),(\d{0,2})/)
        type = $2 == 'D' ? -1 : 1
        transaction = MT940::Transaction.new(amount: type * ($3 + '.' + $4).to_f)
        transaction.date = parse_date($1)
        transaction
      end
    end

    def enrich_transaction(transaction, line_86)
      line_86 = line_86.gsub(/:86:/, '')
      case line_86
        when /^(GIRO)\s+(\d+)(.+)/
          transaction.contra_account = $2.rjust(9, '000000000')
          transaction.description = $3.strip
        when /^(\d{2}.\d{2}.\d{2}.\d{3})(.+)/
          transaction.description = $2.strip
          transaction.contra_account = $1.gsub('.', '')
        when /\/TRTP\/SEPA OVERBOEKING/
          description_parts = line_86[4..-1].split('/')
          transaction.contra_account_iban = parse_description_after_tag description_parts, "IBAN"
          transaction.contra_account = iban_to_account transaction.contra_account_iban
          transaction.contra_account_owner = parse_description_after_tag description_parts, "NAME"
          transaction.description = parse_description_after_tag description_parts, "REMI"
        when /SEPA IDEAL/
          if line_86.match /OMSCHRIJVING\:(.+)?/
            transaction.description = $1.strip
          end
          if line_86.match /IBAN\:(.+)?BIC\:/
            transaction.contra_account_iban = $1.strip
            transaction.contra_account = iban_to_account transaction.contra_account_iban
          end
          if line_86.match /NAAM\:(.+)?OMSCHRIJVING\:/
            transaction.contra_account_owner = $1.strip
          end
        when /SEPA ACCEPTGIROBETALING/
          if line_86.match /(BETALINGSKENM\.\:.+)/
            transaction.description = $1.strip
          end
          if line_86.match /IBAN\:(.+)?BIC\:/
            transaction.contra_account_iban = $1.strip
            transaction.contra_account = iban_to_account transaction.contra_account_iban
          end
          if line_86.match /NAAM\:(.+)?BETALINGSKENM\.\:/
            transaction.contra_account_owner = $1.strip
          end
        else
          transaction.description = line_86
      end
    end
  end
end
