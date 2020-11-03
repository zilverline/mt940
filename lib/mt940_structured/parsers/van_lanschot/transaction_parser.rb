module MT940Structured::Parsers::VanLanschot
  class TransactionParser
    include MT940Structured::Parsers::DateParser
    include MT940Structured::Parsers::IbanSupport
    include MT940Structured::Parsers::StructuredDescriptionParser
    include MT940Structured::Parsers::DefaultLine61Parser

    def get_regex_for_line_61
      /^:61:(\d{6})(\d{4})?(C|D)(\d+),(\d{0,2})/
    end

    def enrich_transaction(transaction, line_86)
      description = line_86[4..-1]
      transaction.description = ""
      keywords = ["BENM", "NAME", "ISDT", "REMI", "CSID", "MARF", "EREF", "ORDP", "ADDR", "CDTRREF", "CDTRREFTP", "IBAN", "BIC"]
      unless keywords.map { |key| "/#{key}/" }.any? { |key| description.include? key }
        if description.match /^(\d{10})/
          transaction.contra_account= description[0..9].gsub(/^0+/, '')
          transaction.description = description[10..-1].strip
        else
          transaction.description = description.strip
        end
      else

        keywords.each do |keyword|
          keyword_with_slashes = "/" + keyword + "/"
          parts = description.split(keyword_with_slashes)
          if parts.length > 1
            part = parts[1].split(/\/BENM\/|\/NAME\/|\/ISDT\/|\/REMI\/|\/CSID\/|\/MARF\/|\/EREF\/|\/ORDP\/|\/ADDR\/|\/CDTRREF\/|\/CDTRREFTP\/|\/IBAN\/|\/BIC\//)
            info = part[0].strip.gsub(/\r|\n/, '')
            if info.length > 0
              case keyword
                when "REMI"
                  transaction.description = info
                when "IBAN"
                  transaction.contra_account_iban = info
                  transaction.contra_account = iban_to_account(info) if iban?(info)
                when "NAME"
                  transaction.contra_account_owner = info
                when "EREF"
                  transaction.eref = info
                when "CDTRREF"
                  transaction.description = "BETALINGSKENMERK #{info}" if transaction.description == ''
              end
            end
          end
        end
      end

    end
  end
end
