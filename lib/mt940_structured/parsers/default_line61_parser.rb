module MT940Structured::Parsers
  ##
  # Basic line 61 parser. Retrieves the date and amount from the line :61:.
  # This module expects that a method get_regex_for_line_61 exists that returns
  # a regex that will, if matched, produces the following groups:
  # $1 - the transaction date
  # $2 - the accounting date (optional)
  # $3 - D for Debit, C for Credit transactions
  # $4 - The amount of the transaction before the cent mark.
  # $5 - The cents of the transaction
  # $6 - The swift code (3 chars after N, optional)
  # $7 - Reference numbers (customer//bank)
  #
  module DefaultLine61Parser
    def get_regex_for_line_61
      raise 'Override this when using this module'
    end

    def parse_transaction(line_61)
      if line_61.match(get_regex_for_line_61)
        type = $3 == 'D' ? -1 : 1
        references = extract_references($7)
        transaction = MT940::Transaction.new(amount: type * ($4 + '.' + $5).to_f)
        transaction.customer_reference = references[:customer]
        transaction.bank_reference = references[:bank]
        transaction.date = parse_date($1)
        transaction.date_accounting = $2 ? parse_date($1[0..1] + $2) : transaction.date
        transaction
      end
    end

    private

    def extract_references(string)
      references = string ? string.split('//') : []
      { customer: references[0] || '', bank: references[1] || '' }
    end
  end
end
