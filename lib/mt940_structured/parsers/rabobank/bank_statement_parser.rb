module MT940Structured::Parsers::Rabobank
  class BankStatementParser
    include DateParser, BalanceParser
    attr_reader :bank_statement

    def initialize(lines)
      @bank_statement = MT940::BankStatement.new([])
      lines.each do |line|
        if line.match /^:(\d{2}(F|C)?):/
          parse_method = "parse_line_#{$1}".to_sym
          send(parse_method, line) if respond_to? parse_method
        else
          raise "nyi '#{$1}' - line #{line}"
        end
      end
    end

    def parse_line_25(line)
      line.gsub!('.', '')
      case line
        when /^:\d{2}:NL/
          @bank_statement.bank_account_iban = line[4, 18]
          @bank_statement.bank_account = @bank_statement.bank_account_iban.strip.split(//).last(10).join.sub(/^[0]*/, "")
          @is_structured_format = true
        when /^:\d{2}:\D*(\d*)/
          @bank_statement.bank_account = $1.gsub(/\D/, '').gsub(/^0+/, '')
          @is_structured_format = false
        else
          raise "Unknown format for tag 25: #{line}"
      end
    end

    def parse_line_60F(line)
      @bank_statement.previous_balance = parse_balance(line)
    end

    def parse_line_61(line)
      @transaction_parser = @is_structured_format ? StructuredTransactionParser.new : TransactionParser.new
      transaction = @transaction_parser.parse_transaction(line)
      transaction.bank_account = @bank_statement.bank_account
      transaction.bank_account_iban = @bank_statement.bank_account_iban
      transaction.currency = @bank_statement.previous_balance.currency
      transaction.bank = "Rabobank"
      @bank_statement.transactions << transaction
    end

    def parse_line_86(line)
      @transaction_parser.enrich_transaction(@bank_statement.transactions.last, line)
    end

    def parse_line_62F(line)
      @bank_statement.new_balance = parse_balance(line)
    end
  end

end
