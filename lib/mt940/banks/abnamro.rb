class MT940::Abnamro < MT940::Base

  def self.determine_bank(*args)
    self if args[0].match(/ABNANL/)
  end

  def mt_940_start_line?(line)
    super || line.match(/ABNANL/)
  end

  def parse_tag_61
    if @line.match(/^:61:(\d{6})\d{4}(C|D)(\d+),(\d{0,2})/)
      type = $2 == 'D' ? -1 : 1
      @transaction = MT940::Transaction.new(:bank_account => @bank_account, :amount => type * ($3 + '.' + $4).to_f, :bank => @bank, :currency => @currency)
      @transaction.date = parse_date($1)
      @bank_statement.transactions << @transaction
      @tag86 = false
    end
  end

  def parse_line
    super unless @skip_parse_line
  end


  def parse_contra_account
    if @transaction

      case @transaction.description
        when /^(GIRO)\s+(\d+)(.+)/
          @transaction.contra_account = $2.rjust(9, '000000000')
          @transaction.description = $3
        when /^(\d{2}.\d{2}.\d{2}.\d{3})(.+)/
          @transaction.description = $2.strip
          @transaction.contra_account = $1.gsub('.', '')
        when /\/TRTP\/SEPA OVERBOEKING/
          description_parts = @line[4..-1].split('/')
          @transaction.contra_account_iban = parse_description_after_tag description_parts, "IBAN"
          @transaction.contra_account = iban_to_account @transaction.contra_account_iban
          @transaction.contra_account_owner = parse_description_after_tag description_parts, "NAME"
          @transaction.description = parse_description_after_tag description_parts, "REMI"
        when /SEPA IDEAL/
          read_all_description_lines!
          full_description = @transaction.description
          if full_description.match /OMSCHRIJVING\:(.+)?/
            @transaction.description = $1.strip
          end
          if full_description.match /IBAN\:(.+)?BIC\:/
            @transaction.contra_account_iban = $1.strip
            @transaction.contra_account = iban_to_account @transaction.contra_account_iban
          end
          if full_description.match /NAAM\:(.+)?OMSCHRIJVING\:/
            @transaction.contra_account_owner = $1.strip
          end
        when /SEPA ACCEPTGIROBETALING/
          read_all_description_lines!
          full_description = @transaction.description
          if full_description.match /(BETALINGSKENM\.\:.+)/
            @transaction.description = $1.strip
          end
          if full_description.match /IBAN\:(.+)?BIC\:/
            @transaction.contra_account_iban = $1.strip
            @transaction.contra_account = iban_to_account @transaction.contra_account_iban
          end
          if full_description.match /NAAM\:(.+)?BETALINGSKENM\.\:/
            @transaction.contra_account_owner = $1.strip
          end
        else
          @skip_parse_line = false
      end
    end
  end

  private

  def read_all_description_lines!
    @skip_parse_line = true
    index = @lines.index(@line)
    @lines[index+1..-1].each do |line|
      break if line.match /^:(\d{2}(F|C)?):/
      @transaction.description.lstrip!
      @transaction.description += ' ' + line.gsub(/\n/, ' ').gsub(/>\d{2}\s*/, '').gsub(/\-XXX/, '').gsub(/-$/, '').strip
      @transaction.description.strip!
    end
  end

  def iban_to_account(iban)
    !iban.nil? ? iban.split(//).last(10).join.gsub(/^0+/, '') : nil
  end

end
