module MT940Structured::Parsers::DeutscheBank
  class TransactionParser
    include MT940Structured::Parsers::DateParser
    include MT940Structured::Parsers::DefaultLine61Parser

    def get_regex_for_line_61
      /^:61:(\d{6})(\d{4})?(C|D)(\d+),(\d{0,2})N(.{3})(.*)?/
    end

    def enrich_transaction(transaction, line_86)
      if line_86.match(/^:86:\s?(.*)\Z/m)
        temp_description = $1.gsub(/\r\n|\n/, '').strip
        transaction.sepa_business_code = temp_description.split('?').first
        transaction.type = parse_swift_tags(temp_description, ['00'])
        temp_account  = parse_swift_tags(temp_description, [31])
        temp_bankcode = parse_swift_tags(temp_description, [30])
        transaction.description          = parse_swift_tags(temp_description, 20..29)
        transaction.contra_bank_code     = only_unless_sepa(temp_bankcode)
        transaction.contra_account       = only_unless_sepa(temp_account)
        transaction.contra_bic           = only_if_sepa(temp_bankcode)
        transaction.contra_account_iban  = only_if_sepa(temp_account)
        transaction.contra_account_owner = parse_swift_tags(temp_description, 32..33)
      end
    end

    private

    def parse_swift_tags(text, tags)
      tags = tags.to_a if tags.kind_of? Range
      value = tags.collect do |tag|
        $1 if text.match(/\?#{tag}([^\?]*)/)
      end
      value.join
    end

    def only_if_sepa(iban_or_bic)
      iban_or_bic unless iban_or_bic =~ /^[0-9\s]+$/
    end

    def only_unless_sepa(account_or_bank_code)
      account_or_bank_code if account_or_bank_code =~ /^[0-9\s]+$/
    end
  end
end
