module MT940Structured
  module Parser
    def parse_mt940(path)
      # parse file
      file_content = FileContent.new(path)
      line_parser = file_content.get_header.parser
      file_content.group_lines
      foo = group_by_atsga

      foo.map { |line| header.parser.parse_line(line) }

      # determine bank
      # transform into transactions

      # create output
    end
  end

  class FileContent
    def initialize(path)
      @raw_lines = File.open(path).readlines
    end

    def get_header
      Header.new(@raw_lines)
    end
  end

  class Header
    R_RABOBANK = /^:940:/
    R_ABN_AMRO = /ABNANL/
    R_TRIODOS = /^:25:TRIODOSBANK/
    R_ING = /INGBNL/

    def initialize(raw_lines)
      @raw_lines = raw_lines
    end

    def parser
      if @raw_lines[0].match(R_RABOBANK)
        LineParsers::Rabobank.new
      elsif @raw_lines[0].match(R_ABN_AMRO)
        LineParsers::AbnAmro.new
      elsif @raw_lines[1] && @raw_lines[1].match(R_TRIODOS)
        LineParsers::Triodos.new
      elsif @raw_lines[0].match(R_ING)
        LineParsers::Ing.new
      else
        raise UnsupportedBankError.new
      end
    end
  end

  class UnsupportedBankError < StandardError

  end
end
