module MT940Structured::Parsers
  class BankStatementParser
    include DateParser, BalanceParser, IbanSupport
    def initialize(bank, transaction_parsers, &completed_transaction_callback)
      @bank = bank
      @transaction_parsers = transaction_parsers
      @empty_statement = true
      @current_transaction = nil
      @bank_statement = MT940::BankStatement.new([])
      @completed_transaction_callback = completed_transaction_callback
    end

    def reset
      @empty_statement = true
      @current_transaction = nil
      @bank_statement = MT940::BankStatement.new([])
    end

    def bank_statement
      return nil unless @bank_statement.bank_account
      @bank_statement unless @empty_statement
    end

    def parse_line(line)
      if line.match /^:(\d{2})(F|C|M)?:/
        @empty_statement = false
        parse_method = "parse_line_#{$1}".to_sym
        send(parse_method, line) if respond_to? parse_method
      else
        raise "nyi '#{$1}' - line #{line}"
      end
    end

    def parse_line_28(line)
      if line && line.match(/^:28C?:(.+)/)
        @bank_statement.page_number = $1.strip
      end
    end

    def parse_line_25(line)
      line.gsub!('.', '')
      case line
      when /^:\d{2}:([a-zA-Z]{2}[0-9]{2}[a-zA-Z0-9\s]{0,30})/
        # older files have the suffix EUR behind the iban number. We do not use this.
        @bank_statement.bank_account_iban = $1.gsub(' ', '').gsub(/EUR$/, '')
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

    def flush_transaction
      @completed_transaction_callback.call(@current_transaction) if @current_transaction
      @current_transaction = nil
    end

    def parse_line_61(line_61)
      flush_transaction()

      @is_structured_format = @transaction_parsers.structured?(line_61) if @transaction_parsers.respond_to?(:structured?)
      @transaction_parser = @transaction_parsers.for_format @is_structured_format
      transaction = @transaction_parser.parse_transaction(line_61)
      transaction.bank_account = @bank_statement.bank_account
      transaction.bank_account_iban = @bank_statement.bank_account_iban
      transaction.currency = @bank_statement.previous_balance.currency
      transaction.bank = @bank
      @current_transaction = transaction
    end

    def parse_line_86(line)
      @transaction_parser.enrich_transaction(@current_transaction, line) if @current_transaction
    end

    def parse_line_62(line)
      @bank_statement.new_balance = parse_balance(line)
    end
  end
end
