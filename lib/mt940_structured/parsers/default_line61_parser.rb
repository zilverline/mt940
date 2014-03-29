module MT940Structured::Parsers
  module DefaultLine61Parser
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
