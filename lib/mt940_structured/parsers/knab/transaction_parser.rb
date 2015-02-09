module MT940Structured::Parsers::Knab
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
      transaction.description = line_86
      if line_86.match /REK:/
        contra_parts = line_86[line_86.index("REK:")..-1].split("/NAAM:")
        account = contra_parts.first.gsub("REK:", "").strip
        transaction.contra_account=iban?(account) ? iban_to_account(account) : account
        transaction.contra_account_iban = account if iban?(account)
        transaction.contra_account_owner = contra_parts.last.strip if contra_parts.length == 2
      end
    end
  end
end
