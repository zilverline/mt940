module MT940Structured
  class Parser
    def self.streaming_mt940_parser(io, handler, join_lines_by = ' ')
      MT940Structured::StreamingParser.new(io, handler, join_lines_by)
    end

    def self.parse_mt940_io(io, join_lines_by = ' ')
      handler = DefaultHandler.new
      MT940Structured::StreamingParser.new(io, handler, join_lines_by)
      handler.bank_statements
    end

    def self.parse_mt940(path, join_lines_by = ' ')
      parse_mt940_io(File.open(path), join_lines_by)
    end

    def self.bank_name_io(io, join_lines_by = ' ')
      handler = NameHandler.new
      catch(:got_name) do
        MT940Structured::StreamingParser.new(io, handler, join_lines_by)
      end
      handler._bank_name
    end

    def self.bank_name(path, join_lines_by = ' ')
      bank_name_io(File.open(path), join_lines_by)
    end

    class NameHandler
      attr_reader :_bank_name
      def end_bank_statement(_stmt)
      end
      def transaction(_tx)
      end
      def bank_name(bank_name)
        @_bank_name = bank_name
        throw :got_name
      end
    end

    class DefaultHandler
      attr_reader :bank_statements
      def initialize
        @bank_statements = Hash.new { |h, k| h[k] = [] }
        @transactions = []
      end

      def bank_name(_bank_name)
      end

      def end_bank_statement(stmt)
        stmt.transactions = @transactions
        @bank_statements[stmt.bank_account] << stmt
        @transactions = []
      end

      def transaction(tx)
        @transactions << tx
      end
    end
  end
end
