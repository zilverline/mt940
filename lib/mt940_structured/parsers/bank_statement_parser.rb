module MT940Structured::Parsers
  class BankStatementParser
    include DateParser, BalanceParser, IbanSupport
    attr_reader :bank_statement

    def initialize(bank, transaction_parsers, lines)
      @bank = bank
      @transaction_parsers = transaction_parsers
      @bank_statement = MT940::BankStatement.new([])
      lines.each do |line|
        if line.match /^:(\d{2})(F|C|M|P)?:/
          parse_method = "parse_line_#{$1}".to_sym
          send(parse_method, line) if respond_to? parse_method
        else
          raise "nyi '#{$1}' - line #{line}"
        end
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
        # Rolled back to previous as the account number ($1) was getting truncated when it had a - 
        # Also added the removal of leading 0's to the original
        # @bank_statement.bank_account = $1.gsub(/\D/, '').gsub(/^0+/, '')
        # @bank_statement.bank_account = line[4 .. -1] #original
        @bank_statement.bank_account = line[4 .. -1].gsub(/^0+/, '')
        @is_structured_format = false
       when /^:\d{2}:IE/
          #puts "B4"
          @bank_statement.bank_account_iban = line[4, 18]
          @bank_statement.bank_account = iban_to_account(@bank_statement.bank_account_iban)
          @is_structured_format = true
      when /^:\d{2}P:(\d*)\s.*/
        @bank_statement.bank_account = $1.gsub(/^0+/, '')
        @is_structured_format = false
       else
          #puts "B5"
          @bank_statement.bank_account = line[4, 18]
          @is_structured_format = false
      end
    end

    def parse_line_60(line)
      @bank_statement.previous_balance = parse_balance(line)
    end

    def parse_line_61(line_61)
      @is_structured_format = @transaction_parsers.structured?(line_61) if @transaction_parsers.respond_to?(:structured?)
      @transaction_parser = @transaction_parsers.for_format @is_structured_format
      begin
        transaction = @transaction_parser.parse_transaction(line_61)
        transaction.bank_account = @bank_statement.bank_account
        transaction.bank_account_iban = @bank_statement.bank_account_iban
        transaction.currency = @bank_statement.previous_balance.currency
        transaction.bank = @bank
      rescue
        err= "Problem parsing a transaction: " + line_61
        #puts err
        raise err
      end
      @bank_statement.transactions << transaction
    end

    def parse_line_86(line)
      @transaction_parser.enrich_transaction(@bank_statement.transactions.last, line)
    end

    def parse_line_62(line)
      @bank_statement.new_balance = parse_balance(line)
    end

    # def parse_line_64(line)
    #   @bank_statement.new_balance = parse_balance(line,-1)
    # end
  end

end
