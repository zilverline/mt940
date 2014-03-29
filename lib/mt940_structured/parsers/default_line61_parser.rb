module MT940Structured::Parsers
  ##
  # Basic line 61 parser. Retrieves the date and amount from the line :61:.
  # This module expects that a method get_regex_for_line_61 exists that returns
  # a regex that will, if matched, produces the following groups:
  # $1 - the transaction date
  # $2 - D for Debit, C for Credit transactions
  # $3 - The amount of the transaction before the cent mark.
  # $4 - The cents of the transaction
  #
  module DefaultLine61Parser
    def get_regex_for_line_61
      raise 'Override this when using this module'
    end

    def parse_transaction(line_61)
      if line_61.match(get_regex_for_line_61)
        type = $2 == 'D' ? -1 : 1
        transaction = MT940::Transaction.new(amount: type * ($3 + '.' + $4).to_f)
        transaction.date = parse_date($1)
        transaction
      end
    end
  end
end
