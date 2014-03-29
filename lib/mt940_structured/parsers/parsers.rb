module MT940Structured
  module Parsers
    class Ing

    end

  end
end

require_relative 'balance_parser'
require_relative 'date_parser'
require_relative 'iban_support'
require_relative 'structured_description_parser'
require_relative 'default_line61_parser'
require_relative 'bank_statement_parser'
require_relative 'base'
require_relative 'tridios/triodos'
require_relative 'abnamro/abnamro'
require_relative 'rabobank/rabobank'
