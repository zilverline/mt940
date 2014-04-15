module MT940Structured::Parsers
  class Base
    def initialize(bank, transaction_parsers)
      @bank = bank
      @transaction_parsers = transaction_parsers
    end

    def transform(lines)
      bank_statements = Hash.new { |h, k| h[k] = [] }
      result = group_lines_by_tag(lines)
      result.each do |bank_statement_lines|
        bank_statement = BankStatementParser.new(@bank, @transaction_parsers, bank_statement_lines).bank_statement
        bank_statements[bank_statement.bank_account] << bank_statement
      end
      bank_statements
    end

    private
    def group_lines_by_tag(lines)
      result = []
      while !lines.empty? do
        start_index = lines.index { |line| line.match(/^:20:/)}
        end_index = lines.index { |line| line.match(/^:62(F|M):/)}
        if start_index && end_index > start_index
          result << lines[start_index..end_index]
          lines = lines.drop(end_index + 1)
        else
          lines = []
        end
      end
      result
    end
  end
end
