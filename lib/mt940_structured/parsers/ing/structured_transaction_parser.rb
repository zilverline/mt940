module MT940Structured::Parsers::Ing
  class StructuredTransactionParser < TransactionParser
    include MT940Structured::Parsers::DateParser,
            Types,
            MT940Structured::Parsers::StructuredDescriptionParser,
            MT940Structured::Parsers::IbanSupport

    IBAN = %Q{[a-zA-Z]{2}[0-9]{2}[a-zA-Z0-9]{0,30}}
    BIC = %Q{[a-zA-Z0-9]{8,11}}
    IBAN_BIC_R = /^(#{IBAN})(?:\s)(#{BIC})(?:\s)(.*)/
    MT940_UNSTRUCTURED_REMI = /\/#{REMI}\/USTD\/\//
    MT940_IBAN_R = /(\/CNTP\/)|(\/EREF\/)|(\/#{REMI}\/)/
    CONTRA_ACCOUNT_DESCRIPTION_R = /^(.*)\sN\s?O\s?T\s?P\s?R\s?O\s?V\s?I\s?D\s?E\s?D\s?(.*)/
    SEPA = "S\s?E\s?P\s?A"

    def enrich_transaction(transaction, line_86)
      if line_86.match(/^:86:\s?(.*)\Z/m)
        description = $1.gsub(/>\d{2}/, '').strip
        case description
          when MT940_IBAN_R
            description_parts = description.split('/').map(&:strip)
            if description_parts.index { |d| d =~ REMI_R } && (description_parts.index { |d| d =~ REMI_R } + 3) < description_parts.size-1
              description_parts = description_parts[0..(description_parts.index { |d| d =~ REMI_R } + 2)] + [description_parts[(description_parts.index { |d| d =~ REMI_R } +3 )..description_parts.size-1].join('/')]
            end
            if description =~ /\/#{CNTP}\//
              transaction.contra_account_iban = parse_description_after_tag description_parts, CNTP_R, 1
              transaction.contra_account = iban_to_account(transaction.contra_account_iban) if transaction.contra_account_iban.match /^NL/
              transaction.contra_account_owner = parse_description_after_tag description_parts, CNTP_R, 3
              transaction.contra_bic = parse_description_after_tag description_parts, CNTP_R, 2
              transaction.description = parse_description_after_tag description_parts, REMI_R, 3
            elsif description =~ MT940_UNSTRUCTURED_REMI
              unstructured_description = parse_description_after_tag description_parts, USTD_R, 2
              if unstructured_description.match(/(.*)(\d\d-\d\d-\d\d\d\d\s\d\d:\d\d.*$)/)
                transaction.contra_account_owner = $1.strip
                transaction.description = $2.strip
              else
                transaction.description = description
              end
            else
              transaction.description = description
            end
          when IBAN_BIC_R
            parse_structured_description transaction, $1, $3
          when /^Europese Incasso, doorlopend(.*)/
            description.match(/^Europese Incasso, doorlopend\s(#{IBAN})\s(#{BIC})(.*)\s([a-zA-Z0-9[:space:]]{19,30})\s#{SEPA}(.*)/)
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
