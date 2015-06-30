module MT940Structured::Parsers
  module StructuredDescriptionParser

    # abbreviations in iban mt940 spec
    # remittance info
    REMI = %Q{R\\s?E\\s?M\\s?I\\s?}
    REMI_R = /#{REMI}/

    #coutner party data
    CNTP = %Q{C\\s?N\\s?T\\s?P\\s?}
    CNTP_R = /#{CNTP}/

    # /REMI/USTD// indicates unstructured remittance info
    USTD = %Q{U\\s?S\\s?T\\s?D\\s?}
    USTD_R = /#{USTD}/

    # End to End Reference
    EREF = %Q{E\\s?R\\s?E\\s?F\\s?}
    EREF_R = /#{EREF}/

    # IBAN
    IBAN = %Q{I\\s?B\\s?A\\s?N\\s?}
    IBAN_R = /#{IBAN}/

    # NAME
    NAME = %Q{N\\s?A\\s?M\\s?E\\s?}
    NAME_R = /#{NAME}/

    def parse_description_after_tag(description_parts, tag, number_of_parts = 1)
      description_start_index = description_parts.index { |part| part =~ tag }
      if description_start_index and description_parts[description_start_index + number_of_parts]
        description_parts[description_start_index + number_of_parts].strip
      else
        ''
      end
    end

  end
end
