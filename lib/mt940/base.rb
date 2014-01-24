module MT940

  class Base

    attr_accessor :bank, :opening_balance, :opening_date

    def self.parse_mt940(file)
      file = File.open(file) if file.is_a?(String)
      if file.is_a?(File) || file.is_a?(Tempfile)
        first_line = file.readline
        second_line = file.readline unless file.eof?
        klass = determine_bank(first_line, second_line)
        file.rewind
        instance = klass.new(file)
        file.close
        instance.parse
      else
        raise ArgumentError.new('No file is given!')
      end
    end

    def parse
      @tag86 = false
      @lines.each do |line|
        @line = line
        @line.match(/^:(\d{2}(F|C)?):/) ? send("parse_tag_#{$1}".to_sym) : parse_line
      end
      @bank_statements
    end

    private

    def self.determine_bank(*args)
      Dir.foreach(File.dirname(__FILE__) + '/banks/') do |file|
        if file.match(/\.rb$/)
          klass = eval(file.gsub(/\.rb$/, '').capitalize)
          bank = klass.determine_bank(*args)
          return bank if bank
        end
      end
      self
    end

    def initialize(file)
      @bank_statements = {}
      @transactions = []
      @bank = self.class.to_s.split('::').last
      @bank = 'Unknown' if @bank == 'Base'
      temp_lines = file.readlines
      @lines = []
      index_of_temp_lines = 0
      index_in_lines = 0
      while index_of_temp_lines < temp_lines.size do
        line = temp_lines[index_of_temp_lines]
        if mt_940_start_line?(line)
          @lines << line
          index_in_lines+=1
        else
          @lines[index_in_lines-1] += line
        end
        index_of_temp_lines+=1
      end
    end

    def mt_940_start_line?(line)
      line.match /^:?\d{2}(\D?|\d?):?.*$/
    end

    def parse_tag_25
      @line.gsub!('.', '')
      case @line
        when /^:\d{2}:NL/
          @bank_account_iban = @line[4, 18]
          @bank_account = @bank_account_iban.strip.split(//).last(10).join.sub(/^[0]*/,"")
          @is_structured_format = true
        when /^:\d{2}:\D*(\d*)/
          @bank_account = $1.gsub(/\D/, '').gsub(/^0+/, '')
          @is_structured_format = false
        else
          raise "Unknown format for tag 25: #{@line}"
      end
      @bank_statements[@bank_account] ||= []
      @tag86 = false
    end

    def parse_tag_28
      @bank_statement = BankStatement.new([], @bank_account, @bank_account_iban, 0, nil, nil)
      @bank_statements[@bank_account] << @bank_statement
    end

    alias_method :parse_tag_28C, :parse_tag_28

    def parse_tag_60F
      @currency = @line[12..14]
      balance_date = parse_date(@line[6..11])

      type = @line[5] == 'D' ? -1 : 1
      amount = @line[15..-1].gsub(",", ".").to_f * type
      @bank_statement.previous_balance = Balance.new(amount, balance_date, @currency)
    end

    def parse_tag_62F
      @currency = @line[12..14]
      balance_date = parse_date(@line[6..11])

      type = @line[5] == 'D' ? -1 : 1
      amount = @line[15..-1].gsub(",", ".").to_f * type

      @bank_statement.new_balance = Balance.new(amount, balance_date, @currency)
    end

    def parse_tag_61
      if @line.match(/^:61:(\d{6})(C|D)(\d+),(\d{0,2})/)
        type = $2 == 'D' ? -1 : 1
        @transaction = MT940::Transaction.new(:bank_account => @bank_account, :amount => type * ($3 + '.' + $4).to_f, :bank => @bank, :currency => @currency)
        @transaction.date = parse_date($1)
        @bank_statement.transactions << @transaction
        @tag86 = false
      end
    end

    def parse_tag_86
      if !@tag86 && @line.match(/^:86:\s?(.*)\Z/m)
        @tag86 = true
        @transaction.description = $1.gsub(/\n/, ' ').gsub(/>\d{2}/, '').strip
        parse_contra_account
      end
    end

    def parse_line
      if @tag86 && @transaction.description
        @transaction.description.lstrip!
        @transaction.description += ' ' + @line.gsub(/\n/, ' ').gsub(/>\d{2}\s*/, '').gsub(/\-XXX/, '').gsub(/-$/, '').strip
        @transaction.description.strip!
      end
    end

    def parse_date(string)
      Date.new(2000 + string[0..1].to_i, string[2..3].to_i, string[4..5].to_i) if string
    end

    def parse_contra_account
    end

    #Fail silently
    def method_missing(*args)
    end

  end

end
