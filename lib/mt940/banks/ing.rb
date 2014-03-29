class MT940::Ing < MT940::Base
  include MT940::StructuredFormat

  IBAN = %Q{[a-zA-Z]{2}[0-9]{2}[a-zA-Z0-9]{0,30}}
  BIC = %Q{[a-zA-Z0-9]{8,11}}
  IBAN_BIC_R = /^(#{IBAN})(?:\s)(#{BIC})(?:\s)(.*)/
  CONTRA_ACCOUNT_DESCRIPTION_R = /^(.*)(?:\s)(?:NOTPROVIDED)(?:\s)(.*)/


  def self.determine_bank(*args)
    self if args[0].match(/INGBNL/)
  end


  def parse_tag_61

    @is_structured_format = @line.match /EREF|PREF|MARF|\d{16}/

    if @line.match(/^:61:(\d{6})(C|D)(\d+),(\d{0,2})N(\S+)/)
      sign = $2 == 'D' ? -1 : 1
      @transaction = MT940::Transaction.new(:bank_account => @bank_account, :amount => sign * ($3 + '.' + $4).to_f, :bank => @bank, :currency => @currency)
      @transaction.type = human_readable_type($5.strip)
      @transaction.date = parse_date($1)
      @bank_statement.transactions << @transaction
      @tag86 = false
    else
      raise @line
    end
  end

  def parse_tag_62F
    super
    @tag86 = true
  end

  def parse_tag_86
    if !@tag86 && @line.match(/^:86:\s?(.*)\Z/m)
      @tag86 = true
      description = $1.gsub(/\n/, ' ').gsub(/>\d{2}/, '').strip
      transaction_has_structured_description = @is_structured_format && @transaction
      @transaction.description = description
      if transaction_has_structured_description && description.match(IBAN_BIC_R)
        parse_structured_description $1, $3
      elsif transaction_has_structured_description && description.match(/^Europese Incasso, doorlopend(.*)/)
        read_all_description_lines!
        @transaction.description.match(/^Europese Incasso, doorlopend\s(#{IBAN})\s(#{BIC})(.*)\s([a-zA-Z0-9[:space:]]{19,30})\sSEPA(.*)/)
        @transaction.contra_account_iban=$1
        @transaction.contra_account_owner=$3.strip
        @transaction.description = "#{$4.strip} #{$5.strip}"
        if @transaction.contra_account_iban.match /^NL/
          @transaction.contra_account=@transaction.contra_account_iban[8..-1].sub(/^0+/, '')
        else
          @transaction.contra_account=@transaction.contra_account_iban
        end
      elsif @transaction && @transaction.description.match(/([P|\d]\d{9})?(.+)/)
        parse_description $1, $2
      else
        @skip_parse_line = false
      end
    end
  end

  def human_readable_type(type)
    ING_MAPPING[type.strip] || type.strip
  end

  ING_MAPPING = {}
  ING_MAPPING["AC"]= "Acceptgiro"
  ING_MAPPING["BA"]= "Betaalautomaattransactie"
  ING_MAPPING["CH"]= "Cheque"
  ING_MAPPING["DV"]= "Diversen"
  ING_MAPPING["FL"]= "Filiaalboeking, concernboeking"
  ING_MAPPING["GF"]= "Telefonisch bankieren"
  ING_MAPPING["GM"]= "Geldautomaat"
  ING_MAPPING["GT"]= "Internetbankieren"
  ING_MAPPING["IC"]= "Incasso"
  ING_MAPPING["OV"]= "Overschrijving"
  ING_MAPPING["PK"]= "Opname kantoor"
  ING_MAPPING["PO"]= "Periodieke overschrijving"
  ING_MAPPING["ST"]= "ST Storting (eigen rekening of derde)"
  ING_MAPPING["VZ"]= "Verzamelbetaling"
  ING_MAPPING["Code"]= "Toelichting"
  ING_MAPPING["CHK"]= "Cheque"
  ING_MAPPING["TRF"]= "Overboeking buitenland"

  private
# introduced by IBAN
  def parse_structured_description(iban, description)
    @transaction.contra_account_iban=iban
    @transaction.description=description
    @transaction.contra_account=@transaction.contra_account_iban[8..-1].sub(/^0+/, '') if @transaction.contra_account_iban.match /^NL/
    if @transaction.description.match CONTRA_ACCOUNT_DESCRIPTION_R
      @transaction.contra_account_owner=$1
      @transaction.description=$2
    end
  end

  def parse_description(account_number, description)
    @transaction.description = description.strip
    number = account_number
    unless number.nil?
      @transaction.contra_account = number.gsub(/\D/, '').gsub(/^0+/, '')
    else
      @transaction.contra_account = "NONREF"
    end
  end

end
