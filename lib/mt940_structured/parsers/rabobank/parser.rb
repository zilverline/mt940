module MT940Structured::Parsers::Rabobank
  class Parser
    def transform(lines)
      bank_statements = Hash.new { |h, k| h[k] = [] }
      result = []
      while !lines.empty? do
        group_size = (lines.drop(1).index { |line| line.match(/^:20:/) } || lines.length) + 1
        result << lines.take(group_size)
        lines = lines.drop(group_size)
      end
      result.each do |bank_statement_lines|
        bank_statement = BankStatementParser.new(bank_statement_lines).bank_statement
        bank_statements[bank_statement.bank_account] << bank_statement
      end
      bank_statements
    end
  end
end
