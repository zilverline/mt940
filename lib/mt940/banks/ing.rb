class MT940::Ing < MT940::Base

  def self.determine_bank(*args)
    self if args[0].match(/INGBNL/)
  end

  def parse_contra_account
    if @transaction && @transaction.description.match(/([P|\d]\d{9})?(.+)/)
      @transaction.description = $2
      number = $1
      unless number.nil?
        @transaction.contra_account = number.gsub(/\D/, '').gsub(/^0+/, '')
      else
        @transaction.contra_account = "NONREF"
      end
    end
  end

end