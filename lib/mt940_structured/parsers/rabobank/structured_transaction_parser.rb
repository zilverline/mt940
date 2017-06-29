module MT940Structured::Parsers::Rabobank
  class StructuredTransactionParser
    include MT940Structured::Parsers::DateParser,
            Types,
            MT940Structured::Parsers::StructuredDescriptionParser,
            MT940Structured::Parsers::IbanSupport


    def parse_transaction(line_61)
      valuta_date = parse_date(line_61[4, 6])
      sign = line_61[10, 1] == 'D' ? -1 : 1
      amount = sign * line_61[11, 15].gsub(',', '.').to_f
      transaction_type = human_readable_type(line_61[27, 3])
      parts = line_61.split(/\s/)
      potential_iban = parts.size > 1 ? parts.last.gsub(/^[P]{0,1}0*/, '').strip : nil
      number = potential_iban.nil? ? "NONREF" : iban_to_account(potential_iban)
      contra_account_iban = iban?(potential_iban) ? potential_iban : nil
      MT940::Transaction.new(amount: amount,
                             type: transaction_type,
                             date: valuta_date,
                             contra_account_iban: contra_account_iban,
                             contra_account: number.strip)

    end

    def enrich_transaction(transaction, line_86)
      description = line_86[4..-1]
      transaction.description = ""
      keywords = ["BENM", "NAME", "ISDT", "REMI", "CSID", "MARF", "EREF", "ORDP", "ADDR", "CDTRREF", "CDTRREFTP"]

      # Sometimes Rabobank send the keyword /REMI/ twice.
      # The spec (https://www.rabobank.nl/images/rib-formaatbeschrijving-swift-mt940s_29888655.pdf)
      # is unclear if this is allowed or not, but it is probably a bug.
      #
      # Since it is unlikely they will fix it within a day, we will fix it for them
      # You're welcome Rabobank.
      #
      # So if this happens we can safely remove the empty /REMI/
      if description.scan(/\/REMI\//).count > 1
        description = description.sub(/\/REMI\/\//, "/")
      end

      keywords.each do |keyword|
        keyword_with_slashes = "/" + keyword + "/"
        parts = description.split(keyword_with_slashes)
        if parts.length > 1
          part = parts[1].split(/\/BENM\/|\/NAME\/|\/ISDT\/|\/REMI\/|\/CSID\/|\/MARF\/|\/EREF\/|\/ORDP\/|\/ADDR\/|\/CDTRREF\/|\/CDTRREFTP\//)
          info = part[0].strip.gsub(/\r|\n/, '')
          if info.length > 0
            case keyword
              when "REMI"
                transaction.description = info
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
