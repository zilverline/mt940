module MT940Structured::Parsers
  class CounterParty < Struct.new(:iban, :bic, :name, :city)

  end
end
