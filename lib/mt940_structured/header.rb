module MT940Structured
  class Header
    R_RABOBANK = /^:940:/
    R_ABN_AMRO = /ABNANL/
    R_TRIODOS = /^:25:TRIODOSBANK/
    R_ING = /INGBNL/
    R_DEUTSCHE_BANK = /:20:DEUTDE/
    R_KNAB = /KNABNL/
    R_VAN_LANSCHOT = /FVLBNL/
    R_SNS = /SNSBNL/
    R_ASN = /ASNBNL/
    R_REGIO_BANK = /RBRBNL/

    def self.parser(line)
      if line.match(R_RABOBANK)
        MT940Structured::Parsers::Rabobank::Parser.new
      elsif line.match(R_ABN_AMRO)
        MT940Structured::Parsers::Abnamro::Parser.new
      elsif line.match(R_TRIODOS)
        MT940Structured::Parsers::Triodos::Parser.new
      elsif line.match(R_ING)
        MT940Structured::Parsers::Ing::Parser.new
      elsif line.match(R_DEUTSCHE_BANK)
        MT940Structured::Parsers::DeutscheBank::Parser.new
      elsif line.match(R_KNAB)
        MT940Structured::Parsers::Knab::Parser.new
      elsif line.match(R_VAN_LANSCHOT)
        MT940Structured::Parsers::VanLanschot::Parser.new
      elsif line.match(R_SNS) || line.match(R_ASN) || line.match(R_REGIO_BANK)
        MT940Structured::Parsers::Sns::Parser.new
      else
        nil
      end
    end
  end
end
