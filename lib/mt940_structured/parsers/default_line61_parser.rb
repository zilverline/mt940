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
        #puts "$3 -- #{$3}"
        type = $3 == 'D' ? -1 : ($3 == 'RC' ? -1 : 1)
        references = extract_references($7)
        transaction = MT940::Transaction.new(amount: type * ($4 + '.' + $5).to_f)
        transaction.customer_reference = references[:customer]
        transaction.bank_reference = references[:bank]
        transaction.date = parse_date($1)
        #transaction.date_accounting = $2 ? parse_date($1[0..1] + $2) : transaction.date
        transaction.type = $3
        transaction.date_accounting = date_accounting(transaction.date, $2)
        transaction
      end
    end

    private
    # Case line 61 ":61:1401011229"
    #
    # At the end of the year date accounting can be in the previous year.
    # Since the MT940 "standard" does not provide the year in date accounting
    # we need to calculate it ourselves.
    def date_accounting(date, date_accounting)
      return date unless date_accounting

      if date.month == 1 && date_accounting[0..1] == "12"
        year = date.year - 1
      elsif date.month == 12 && date_accounting[0..1] == "01"
        year = date.year + 1        
      else
        year = date.year
      end

      parse_date(year.to_s[2..3] + date_accounting)
    end

    def extract_references(string)
      references = string ? string.split('//') : []
      { customer: references[0] || '', bank: references[1] || '' }
    end
  end
end
