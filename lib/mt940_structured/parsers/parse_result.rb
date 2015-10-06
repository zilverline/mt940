require_relative 'counter_party'

module MT940Structured::Parsers
  class ParseResult < Struct.new(:eref, :marf, :counter_party, :remi)
  end
end
