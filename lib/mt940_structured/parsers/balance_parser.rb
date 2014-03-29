module MT940Structured::Parsers
  module BalanceParser
    def parse_balance(line)
      currency = line[12..14]
      balance_date = parse_date(line[6..11])
      type = line[5] == 'D' ? -1 : 1
      amount = line[15..-1].gsub(",", ".").to_f * type
      MT940::Balance.new(amount, balance_date, currency)
    end

  end
end
