class MT940::Rabobank < MT940::Base

  def self.determine_bank(*args)
    self if args[0].match(/^:940:/)
  end

  def parse_tag_61
    if @line.match(/^:61:(\d{6})(C|D)(\d+),(\d{0,2})N(.{3})([P|\d]\d{9}|NONREF)\s*(.+)?$/)
      sign = $2 == 'D' ? -1 : 1
      @transaction = MT940::Transaction.new(:bank_account => @bank_account, :amount => sign * ($3 + '.' + $4).to_f, :bank => @bank, :currency => @currency)
      #types: "MSC", "013", "023", "030", "034", "060", "062", "070", "071", "084", "088", "093", "102", "121", "122", "127", "131", "133", "404", "411", "501", "504", "505", "508", "541", "544", "578", "689", "690", "691"
      @transaction.type = $5
      @transaction.date = parse_date($1)
      number = $6.strip
      name = $7 || ""
      number = number.gsub(/\D/, '').gsub(/^0+/, '') unless number == 'NONREF'
      @transaction.contra_account = number
      @transaction.contra_account_owner = name.strip
      @bank_accounts[@bank_account].transactions << @transaction
    else
      raise @line
    end
  end

  def parse_tag_86
    if @line.match(/^:86:(.*)$/)
      @transaction.description = [@transaction.description, $1].join(" ").strip
    end
  end

end
