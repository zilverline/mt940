module MT940Structured::Parsers::Sns
  class TransactionParser
    include MT940Structured::Parsers::DateParser
    include MT940Structured::Parsers::IbanSupport
    include MT940Structured::Parsers::StructuredDescriptionParser
    include MT940Structured::Parsers::DefaultLine61Parser

    def get_regex_for_line_61
      /^:61:(\d{6})(\d{4})?(C|D)(\d+),(\d{0,2})([a-zA-Z]{4})(.*\/\/\d{1,16})?/
    end


    def enrich_transaction(transaction, line_86)
      transaction.contra_account = "NONREF" unless transaction.contra_account
      line_86 = line_86.gsub(/:86:/m, '')
      if line_86.match /^([a-zA-Z]{2}[0-9]{2}[a-zA-Z0-9]{0,30})(.*?)\n(.*)/
        transaction.contra_account_iban = $1.strip
        transaction.contra_account_owner = $2.strip
        transaction.contra_account = iban_to_account(transaction.contra_account_iban)
        transaction.description = $3.strip
      else
        transaction.description = line_86.strip
      end
      transaction
    end
  end
end
