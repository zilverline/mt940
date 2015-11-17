require_relative '../parse_result'

module MT940Structured::Parsers::Ing
  class Line86
    # End of a keyword value
    DOUBLE_SLASH = '\/\\s?\/'
    SINGLE_SLASH = '\/$'
    END_OF_VALUE = "(?:#{DOUBLE_SLASH}|#{SINGLE_SLASH})"
    END_OF_VALUE_R = /#{END_OF_VALUE}/

    # End to End Reference
    EREF = %Q{E\\s?R\\s?E\\s?F\\s?}
    EREF_R = /#{EREF}/

    # Mandate Reference
    MARF = %Q{M\\s?A\\s?R\\s?F\\s?}
    MARF_R = /#{MARF}/

    #coutner party data
    CNTP = %Q{C\\s?N\\s?T\\s?P\\s?}
    CNTP_R = /#{CNTP}/

    # remittance info
    REMI = %Q{R\\s?E\\s?M\\s?I\\s?}

    # unstructured
    USTD = %Q{U\\s?S\\s?T\\s?D\\s?}
    REMI_USTD_R = /#{REMI}\/\s?#{USTD}#{DOUBLE_SLASH}(.*?)#{END_OF_VALUE}/

    # dutch structured
    STRD = %Q{S\\s?T\\s?R\\s?D\\s?}
    CUR = %Q{C\\s?U\\s?R\\s?}
    REMI_STRD_CUR_R = /#{REMI}\/\s?#{STRD}\/\s?#{CUR}\/(.*?)#{END_OF_VALUE}/

    # ISO structured
    ISO = %Q{I\\s?S\\s?O\\s?}
    REMI_STRD_ISO_R = /#{REMI}\/\s?#{STRD}\/\s?#{ISO}\/(.*?)#{END_OF_VALUE}/

    #Timestamp
    TIMESTAMP_R = /(.*)(\d\d-\d\d-\d\d\d\d\s\d\d:\d\d.*$)/


    def self.parse(description)
      result = MT940Structured::Parsers::ParseResult.new
      result.eref = get_single_value description, EREF_R
      result.marf = get_single_value description, MARF_R
      counter_party_string = get_single_value(description, CNTP_R)
      set_counter_party counter_party_string, result
      case description
        when REMI_USTD_R
          result.remi = $1
          if result.counter_party.name.nil? and result.remi.match(TIMESTAMP_R)
            result.counter_party.name = $1.strip
            result.remi = $2.strip
          end
        when REMI_STRD_CUR_R
          result.remi = $1
        when REMI_STRD_ISO_R
          result.remi = $1
        else
          result.remi = description
      end
      result
    end

    private
    def self.set_counter_party(counter_party_string, result)
      result.counter_party = MT940Structured::Parsers::CounterParty.new
      if counter_party_string
        counter_party_data = counter_party_string.split('/')
        result.counter_party.iban = counter_party_data[0]
        result.counter_party.bic = counter_party_data[1]
        result.counter_party.name = counter_party_data[2]
        result.counter_party.city = counter_party_data[3]
      end
    end

    def self.get_single_value(description, keyword_regex)
      position = description.index keyword_regex
      if position
        start_of_value = description.index /\//, position
        end_of_value = description.index END_OF_VALUE_R, start_of_value
        description[start_of_value + 1, (end_of_value - start_of_value - 1)]
      end
    end
  end
end
