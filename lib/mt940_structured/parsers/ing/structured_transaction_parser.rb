module MT940Structured::Parsers::Ing
  class StructuredTransactionParser < TransactionParser
    include MT940Structured::Parsers::DateParser,
            Types,
            MT940Structured::Parsers::StructuredDescriptionParser,
            MT940Structured::Parsers::IbanSupport

    IBAN = %Q{[a-zA-Z]{2}[0-9]{2}[a-zA-Z0-9]{0,30}}
    BIC = %Q{[a-zA-Z0-9]{8,11}}
    IBAN_BIC_R = /^(#{IBAN})(?:\s)(#{BIC})(?:\s)(.*)/
    CONTRA_ACCOUNT_DESCRIPTION_R = /^(.*)\sN\s?O\s?T\s?P\s?R\s?O\s?V\s?I\s?D\s?E\s?D\s?(.*)/

    def enrich_transaction(transaction, line_86)
      if line_86.match(/^:86:\s?(.*)\Z/m)
        description = $1.gsub(/>\d{2}/, '').strip
        case description
          when IBAN_BIC_R
            parse_structured_description transaction, $1, $3
          when /^Europese Incasso, doorlopend(.*)/
            description.match(/^Europese Incasso, doorlopend\s(#{IBAN})\s(#{BIC})(.*)\s([a-zA-Z0-9[:space:]]{19,30})\sSEPA(.*)/)
            transaction.contra_account_iban=$1
            transaction.contra_account_owner=$3.strip
            transaction.description = "#{$4.strip} #{$5.strip}"
            if transaction.contra_account_iban.match /^NL/
              transaction.contra_account=iban_to_account(transaction.contra_account_iban)
            else
              transaction.contra_account=transaction.contra_account_iban
            end
          else
            transaction.description = description
        end
      end
    end

    private
    def parse_structured_description(transaction, iban, description)
      transaction.contra_account_iban=iban
      transaction.description=description
      transaction.contra_account=iban_to_account(iban) if transaction.contra_account_iban.match /^NL/
      if transaction.description.match CONTRA_ACCOUNT_DESCRIPTION_R
        transaction.contra_account_owner=$1
        transaction.description=$2
      end
    end


  end


end
