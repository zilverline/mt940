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
        when /\/TRTP\/(?:SEPA|IDEAL|ACCEPTGIRO)/
          parse_result = Line86.parse(line_86)
          transaction.contra_account_iban = parse_result.counter_party.iban
          transaction.contra_account = iban_to_account transaction.contra_account_iban if transaction.contra_account_iban
          transaction.contra_account_owner = parse_result.counter_party.name
          transaction.description = parse_result.remi
          transaction.eref = parse_result.eref
        when /^(GIRO)\s+(\d+)(.+)/
          transaction.contra_account = $2.rjust(9, '000000000')
          transaction.description = $3.strip
        when /^(\d{2}.\d{2}.\d{2}.\d{3})(.+)/
          transaction.description = $2.strip
          transaction.contra_account = $1.gsub('.', '')
        when /SEPA IDEAL/
          transaction.description = parse_single_value(line_86, /OMSCHRIJVING\:(.+)?/)
          parse_iban_bic(line_86, transaction)
          transaction.contra_account_owner = parse_single_value line_86, /NAAM\:(.+)?OMSCHRIJVING\:/
        when /SEPA ACCEPTGIROBETALING/
          transaction.description = parse_single_value(line_86, /(BETALINGSKENM\.\:.+)/)
          parse_iban_bic(line_86, transaction)
          transaction.contra_account_owner = parse_single_value line_86, /NAAM\:(.+)?BETALINGSKENM\.\:/
        when /SEPA OVERBOEKING/
          transaction.description = parse_single_value(line_86, /OMSCHRIJVING\:(.+)?/)
          parse_iban_bic(line_86, transaction)
          transaction.contra_account_owner = parse_single_value line_86, /NAAM\:(.+)?OMSCHRIJVING\:/
        when /SEPA INCASSO ALGEMEEN DOORLOPEND/
          transaction.description = parse_single_value(line_86, /OMSCHRIJVING\:(.+)?IBAN\:/)
          parse_iban_bic(line_86, transaction)
          transaction.contra_account_owner = parse_single_value line_86, /NAAM\:(.+)?MACHTIGING\:/
        when /SEPA PERIODIEKE OVERB\./
          transaction.description = parse_single_value(line_86, /OMSCHRIJVING\:(.+)?/)
          parse_iban_bic(line_86, transaction)
          transaction.contra_account_owner = parse_single_value line_86, /NAAM\:(.+)?OMSCHRIJVING\:/
        else
          transaction.description = line_86
      end
    end

    private

    def parse_structured_line_86(line_86, transaction)
      description_parts = line_86[4..-1].split('/')
      transaction.contra_account_iban = parse_description_after_tag description_parts, IBAN_R
      transaction.contra_account = iban_to_account transaction.contra_account_iban
      transaction.contra_account_owner = parse_description_after_tag description_parts, NAME_R
      transaction.description = parse_description_after_tag description_parts, REMI_R
    end

    def parse_single_value(line_86, regex)
      $1.strip if line_86.match regex
    end

    def parse_iban_bic(line_86, transaction)
      if line_86.match /IBAN\:\s(.*?)\s/
        transaction.contra_account_iban = $1.strip
        transaction.contra_account = iban_to_account transaction.contra_account_iban
      end
    end
  end
end
