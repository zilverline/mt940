module MT940Structured::Parsers::Rabobank
  class StructuredTransactionParser
    include DateParser,
            Types,
            StructuredDescriptionParser,
            IbanSupport


    def parse_transaction(line_61)
      valuta_date = parse_date(line_61[4, 6])
      sign = line_61[10, 1] == 'D' ? -1 : 1
      amount = sign * line_61[11, 15].gsub(',', '.').to_f
      transaction_type = human_readable_type(line_61[27, 3])
      parts = line_61.split(/\s/)
      potential_iban = parts.size > 1 ? parts.last.gsub(/^[P]{0,1}0*/, '').strip : nil
      number = potential_iban.nil? ? "NONREF" : potential_iban.strip.split(//).last(10).join.gsub(/^0+/, '')
      contra_account_iban = iban?(potential_iban) ? potential_iban : nil
      MT940::Transaction.new(amount: amount,
                             type: transaction_type,
                             date: valuta_date,
                             contra_account_iban: contra_account_iban,
                             contra_account: number.strip)

    end

    def enrich_transaction(transaction, line_86)
      transaction.description = line_86[4..-1]
      description_parts = transaction.description.split('/')
      transaction.description = parse_description_after_tag description_parts, "REMI"
      if transaction.description == ''
        structured_betalingskenmerk = parse_description_after_tag(description_parts, "CDTRREF")
        transaction.description = "BETALINGSKENMERK #{structured_betalingskenmerk}" unless structured_betalingskenmerk == ''
      end
      transaction.contra_account_owner = description_parts[description_parts.index { |part| part == "NAME" } + 1].gsub(/\r|\n/, '') if description_parts.index { |part| part == "NAME" }
      transaction.description.strip!
    end

  end


end
