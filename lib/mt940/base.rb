module MT940

  class Base

    def self.transactions(file_name)
      first_line = File.open(file_name) {|f| f.readline}
      klass = if first_line.match(/INGBNL/)
        ING
      elsif first_line.match(/ABNANL/)
        Abnamro
      elsif first_line.match(/^:940:/)
        Rabobank
      else
        self
      end
      instance = klass.new(file_name)
      instance.parse
      instance.instance_variable_get('@transactions')
    end

    def parse
      @tag86 = false
      @lines.each do |line|
        @line = line
        @line.match(/^:(\d{2}):/) ? eval('parse_tag_'+ $1) : parse_line
      end
      @transactions
    end

    private

    def initialize(file_name)
      @transactions = []
      @lines = File.readlines(file_name)
    end

    def parse_tag_25
      @line.gsub!('.','')
      if @line.match(/^:\d{2}:[^\d]*(\d*)/)
        @bank_account = $1
        @tag86 = false
      end
    end

    def parse_tag_61
      if @line.match(/^:61:(\d{6})(C|D)(\d+),(\d{0,2})/)
        type = $2 == 'D' ? -1 : 1
        @transaction = MT940::Transaction.new(:bank_account => @bank_account, :amount => type * ($3 + '.' + $4).to_f)
        @transaction.date = parse_date($1)
        @transactions << @transaction
        @tag86 = false
      end
    end

    def parse_tag_86
      if !@tag86 && @line.match(/^:86:\s?(.*)$/)
        @tag86 = true
        @transaction.description = $1.gsub(/>\d{2}/,'')
      end
    end

    def parse_line
      @transaction.description += ' ' + @line.gsub(/\n/,'').gsub(/>\d{2}/,'') if @tag86
    end

    def parse_date(string)
      Date.new(2000 + string[0..1].to_i, string[2..3].to_i, string[4..5].to_i) if string
    end

    #Fail silently
    def method_missing(*args)
    end

  end

end
