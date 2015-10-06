module MT940Structured::Parsers
  module Constants

    EREF = RegexSupport.regexify_string('EREF')
    EREF_R = RegexSupport.regexify_keyword('EREF')

    IBAN = RegexSupport.regexify_string('IBAN')
    IBAN_R = RegexSupport.regexify_keyword('IBAN')

    BIC = RegexSupport.regexify_string('BIC')
    BIC_R = RegexSupport.regexify_keyword('BIC')

    NAME = RegexSupport.regexify_string('NAME')
    NAME_R = RegexSupport.regexify_keyword('NAME')

    REMI = RegexSupport.regexify_string('REMI')
    REMI_R = RegexSupport.regexify_keyword('REMI')

    MARF = RegexSupport.regexify_string('MARF')
    MARF_R = RegexSupport.regexify_keyword('MARF')

    CSID = RegexSupport.regexify_string('CSID')
    CSID_R = RegexSupport.regexify_keyword('CSID')

  end
end
