module MT940Structured::Parsers
  module IbanSupport
    IBAN_R = /[a-zA-Z]{2}[0-9]{2}[a-zA-Z0-9]{0,30}/

    def iban?(string)
      !string.nil? and string.match(IBAN_R)
    end
  end

end
