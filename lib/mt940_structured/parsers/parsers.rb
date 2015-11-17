module MT940Structured
  module Parsers
  end
end

require_relative 'regex_support'
require_relative 'constants'
require_relative 'balance_parser'
require_relative 'date_parser'
require_relative 'iban_support'
require_relative 'structured_description_parser'
require_relative 'default_line61_parser'
require_relative 'bank_statement_parser'
require_relative 'base'
require_relative 'tridios/triodos'
require_relative 'ing/ing'
require_relative 'abnamro/abnamro'
require_relative 'generic/generic'
require_relative 'rabobank/rabobank'
require_relative 'deutsche_bank/deutsche_bank'
require_relative 'knab/knab'
require_relative 'van_lanschot/van_lanschot'
require_relative 'sns/sns'
