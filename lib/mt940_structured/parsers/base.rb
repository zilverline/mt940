require 'set'

module MT940Structured::Parsers
  NEXT_LINES_FOR = {
    '20' => ['21','25'],
    '21' => ['25'],
    '25' => ['28'],
    '28' => ['60'],
    '60' => ['61', '62'],
    '61' => ['61', '62', '86'],
    '86' => ['20', '61', '62']
  }
  NO_NEXT_LINES = Set.new(['62','64', '65'])

  class Base
    attr_reader :bank

    def initialize(bank, transaction_parsers, next_lines_for = MT940Structured::Parsers::NEXT_LINES_FOR)
      @bank = bank
      @transaction_parsers = transaction_parsers
      @next_lines_for = next_lines_for
    end

    def transform(lines)
      validate_grouped_lines(lines)
      bank_statements = Hash.new { |h, k| h[k] = [] }
      result = group_lines_by_tag(lines)
      result.each do |bank_statement_lines|
        bank_statement = BankStatementParser.new(@bank, @transaction_parsers, bank_statement_lines).bank_statement
        bank_statements[bank_statement.bank_account] << bank_statement
      end
      bank_statements
    end

    protected
    def validate_grouped_lines(lines)
      lines.each_with_index do |current_line, index|
        if index < (lines.length - 1)
          next_line = lines[index+1]
          next_line_type = next_line[1,2]
          current_line_type = current_line[1, 2]
          next if NO_NEXT_LINES.include?(current_line_type)
          possible_next_line_starts = @next_lines_for[current_line_type]
          raise MT940Structured::InvalidFileContentError.new(%Q{Expected line of type #{possible_next_line_starts} after a #{current_line_type}, but was #{next_line_type}}) unless possible_next_line_starts.include?(next_line_type)
        end
      end
    end

    private
    def group_lines_by_tag(lines)
      result = []
      while !lines.empty? do
        start_index = lines.index { |line| line.match(/^:20:/)}
        end_index = lines.index { |line| line.match(/^:62(F|M):/)}
        optional_avail = lines.index { |line| line.match(/^:64:/)}
        end_index = optional_avail if optional_avail && optional_avail > end_index
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
