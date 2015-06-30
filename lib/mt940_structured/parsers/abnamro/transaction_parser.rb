module MT940Structured::Parsers::Abnamro
  class TransactionParser
    include MT940Structured::Parsers::DateParser
    include MT940Structured::Parsers::IbanSupport
    include MT940Structured::Parsers::StructuredDescriptionParser
    include MT940Structured::Parsers::DefaultLine61Parser

    def get_regex_for_line_61
      /^:61:(\d{6})(\d{4})?(C|D)(\d+),(\d{0,2})/
    end

    def enrich_transaction(transaction, line_86)
      transaction.contra_account = "NONREF" #default
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
          transaction.contra_account_iban = parse_description_after_tag description_parts, IBAN_R
          transaction.contra_account = iban_to_account transaction.contra_account_iban
          transaction.contra_account_owner = parse_description_after_tag description_parts, NAME_R
          transaction.description = parse_description_after_tag description_parts, REMI_R
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
