module MT940Structured::Parsers
  class BankStatementParser
    include DateParser, BalanceParser, IbanSupport
    attr_reader :bank_statement

    def initialize(bank, transaction_parsers, lines)
      @bank = bank
      @transaction_parsers = transaction_parsers
      @bank_statement = MT940::BankStatement.new([])
      lines.each do |line|
        if line.match /^:(\d{2})(F|C|M)?:/
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
          @bank_statement.bank_account = iban_to_account(@bank_statement.bank_account_iban)
          @is_structured_format = true
        when /^:\d{2}:\d+\/(\d+)$/
          @bank_statement.bank_account = $1.gsub(/^0+/, '')
          @is_structured_format = true
        when /^:\d{2}:\D*(\d*)/
          @bank_statement.bank_account = $1.gsub(/\D/, '').gsub(/^0+/, '')
          @is_structured_format = false
        else
          raise "Unknown format for tag 25: #{line}"
      end
    end

    def parse_line_60(line)
      @bank_statement.previous_balance = parse_balance(line)
    end

    def parse_line_61(line_61)
      @is_structured_format = @transaction_parsers.structured?(line_61) if @transaction_parsers.respond_to?(:structured?)
      @transaction_parser = @transaction_parsers.for_format @is_structured_format
      transaction = @transaction_parser.parse_transaction(line_61)
      transaction.bank_account = @bank_statement.bank_account
      transaction.bank_account_iban = @bank_statement.bank_account_iban
      transaction.currency = @bank_statement.previous_balance.currency
      transaction.bank = @bank
      @bank_statement.transactions << transaction
    end

    def parse_line_86(line)
      @transaction_parser.enrich_transaction(@bank_statement.transactions.last, line)
    end

    def parse_line_62(line)
      @bank_statement.new_balance = parse_balance(line)
    end
  end

end
