require_relative '../parse_result'

module MT940Structured::Parsers::Abnamro
  class Line86
    include MT940Structured::Parsers::Constants

    ALL_KEYWORDS_R = /#{BIC}|#{NAME}|#{REMI}|#{EREF}|#{MARF}|#{CSID}|#{IBAN}|$/

    def self.parse(line_86)
      result = MT940Structured::Parsers::ParseResult.new
      result.eref = get_value(line_86, EREF_R)
      result.counter_party = MT940Structured::Parsers::CounterParty.new
      result.counter_party.iban = get_value(line_86, IBAN_R)
      result.counter_party.bic = get_value(line_86, BIC_R)
      result.counter_party.name = get_value(line_86, NAME_R)
      result.remi = get_value(line_86, REMI_R)
      result.marf = get_value(line_86, MARF_R)
      result
    end

    private
    def self.get_value(line_86, keyword_regex)
      position = line_86.index keyword_regex
      if position
        start_of_value = line_86.index(/\//, position + 1)
        end_of_value = line_86.index ALL_KEYWORDS_R, start_of_value
        line_86[start_of_value + 1, (end_of_value - start_of_value - 1)].strip
      end
    end
  end
end

