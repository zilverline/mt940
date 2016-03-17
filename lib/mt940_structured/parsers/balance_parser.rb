module MT940Structured::Parsers
  module BalanceParser
    def parse_balance(line,offset=0)
      currency = line[12+offset..14+offset]
      balance_date = parse_date(line[6+offset..11+offset])
      type = line[5+offset] == 'D' ? -1 : 1
      amount = line[15+offset..-1].gsub(",", ".").to_f * type
      MT940::Balance.new(amount, balance_date, currency)
    end
  end
end
