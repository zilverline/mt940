# https://www.triodos.nl/downloads/betalen/formaatbeschrijving-mt940.pdf
module MT940Structured::Parsers::Triodos
  class TransactionParser
    include MT940Structured::Parsers::DateParser
    include MT940Structured::Parsers::DefaultLine61Parser
    include MT940Structured::Parsers::IbanSupport
    include MT940Structured::Parsers::StructuredDescriptionParser

    def get_regex_for_line_61
      /^:61:(\d{6})(\d{4})?(C|D)(\d+),(\d{0,2})/
    end

    def enrich_transaction(transaction, line_86)
      if line_86.match(/^:86:\s?(.*)\Z/m)
        raw_line = $1.strip
        if new_structured?(raw_line)
          description_parts = line_86[4..-1].split('/')
          transaction.contra_account_iban = parse_description_after_tag(description_parts, CNTP_R)
          transaction.contra_account = iban_to_account(transaction.contra_account_iban)
          transaction.contra_account_owner = parse_description_after_tag(description_parts, CNTP_R, 3)
          transaction.description = parse_description_after_tag(description_parts, REMI_R, 3)
        elsif structured?(raw_line)
          parts = structured_parts(raw_line)
          potential_iban = parts[6].strip
          transaction.contra_account_iban = potential_iban if iban?(potential_iban) # > 21 contains contra account
          transaction.contra_account = iban_to_account(transaction.contra_account_iban) if transaction.contra_account_iban
          start_index = iban?(potential_iban) ? 22 : 20
          transaction.description = description_from(parts, start_index)
        else

          temp_description = raw_line.gsub(/\n/, ' ').gsub(/>\d{2}/, '')
          if temp_description.match(/^\d+(\d{9})(.*)$/)
            transaction.contra_account = $1.rjust(9, '000000000')
            transaction.description = $2.strip
          else
            transaction.description = temp_description
          end
        end
      end

    end

    private
    def new_structured?(line_86)
      line_86.match(/#{CNTP_R}\/[a-zA-Z]{2}[0-9]{2}.*#{REMI_R}/m)
    end
    def structured?(line_86)
      parts = structured_parts(line_86)
      parts.length > 2 && parts[2].strip == '0000000000'
    end

    # Returns array as follows
    #
    # 000
    # >21
    # VALUE 21
    # >22
    # Value 22
    # etc
    def structured_parts(line_86)
      line_86.split(/(>\d{2})/)
    end

    def description_from(parts, start_at)
      (start_at..27).to_a.map{|index|value_for(parts, index)}.join('').strip
    end

    def value_for(parts, identifier)
      index = parts.index(">#{identifier}")
      index && parts.length > index ? parts[index+1] : ""
    end
  end
end
