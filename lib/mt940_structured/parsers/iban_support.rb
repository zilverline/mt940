module MT940Structured::Parsers
  module IbanSupport
    IBAN_R = /[a-zA-Z]{2}[0-9]{2}[a-zA-Z0-9]{0,30}/

    def iban?(string)
      !string.nil? and string.match(IBAN_R)
    end

    def iban_to_account(iban)
      !iban.nil? ? iban.chars.last(10).join.gsub(/^0+/, '') : nil
    end

  end

end
