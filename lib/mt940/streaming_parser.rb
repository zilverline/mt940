module MT940Structured
  class StreamingParser
    R_EOF_ING = /^-XXX$/
    R_EOF_ABN_AMRO = /^-$/
    R_EOF_TRIODOS = /^-$/

    class UnsupportedBankError < StandardError
    end

    def initialize(io, handler, join_lines_by)
      @io = io
      @handler = handler
      @parser = nil
      @transaction = nil
      @in_transactions_body = false
      @start_index = nil
      @end_index = nil
      @previous_tag = nil
      @join_lines_by = join_lines_by
      @current_bank_statement = false

      parse_file()
    end

    def parse_header(line)
      @parser = MT940Structured::Header.parser(line)
      if @parser
        @handler.bank_name(@parser.bank)

        @current_bank_statement = MT940Structured::Parsers::BankStatementParser.new(@parser.bank, @parser.transaction_parsers) do |transaction|
          @handler.transaction(transaction)
        end
      end
    end

    class Validator
      NO_NEXT_LINES = Set.new(['62', '64', '65'])

      def initialize
        @last_line = nil
      end

      def validate_line(line, next_lines_for)
        if(@last_line)
          current_line_type = line[1,2]
          last_line_type = @last_line[1,2]
          return if NO_NEXT_LINES.include? last_line_type
          possible_next_line_starts = next_lines_for[last_line_type]
          raise MT940Structured::InvalidFileContentError.new(%Q{Expected line of type #{possible_next_line_starts} after a #{last_line_type}, but was #{current_line_type}}) unless possible_next_line_starts.include?(current_line_type)
        end

      ensure
        @last_line = line
      end
    end

    def fix_encoding(string)
      string
        .encode('UTF-8', 'binary', :invalid => :replace, :undef => :replace) # remove other obscure chars. god knows what people upload.
        .gsub(/\u001A/, '') # remove eof chars in the middle of the string... yes it happens :-(
        .chomp
        .strip
    end

    def parse_file()
      @validator = Validator.new

      @io.each_line.with_index do |line, index|
        line = fix_encoding(line)
        # puts line.inspect
        parse_start_index(line, index)

        if !@parser
          raise MT940Structured::UnsupportedBankError if index > 1
          parse_header(line)
        end

        if @parser
          start_or_end_bank_statement(line)
          parse_end_index(line, index)
          parse_body_line(line, index)
        end
      end
      raise MT940Structured::InvalidFileContentError if !@current_bank_statement
      end_bank_statement
    end

    def parse_start_index(line, index)
      if line.match /^:20:/
        @in_transactions_body = true
        @start_index = index
      end
    end

    def parse_end_index(line, index)
      if line.match(R_EOF_ING) || line.match(R_EOF_ABN_AMRO) || line.match(R_EOF_TRIODOS)
        @in_transactions_body = false
        @end_index = index
      end
    end

    def flush_line
      @validator.validate_line(@current_line, @parser.next_lines_for) if @current_line
      @current_bank_statement.parse_line(@current_line) if @current_line
      @current_line = nil
    end

    def parse_body_line(line, _index)
      return unless @in_transactions_body

      mt940_line = line.match /^(:(?:20|25|28|60|61|86|62|64|65|86)[D|C|F|M]?:)/

      if mt940_line && @previous_tag != $1
        flush_line()
        @previous_tag = $1
        @current_line = line
      else
        next_line = if line.match /^(:(?:20|25|28|60|61|86|62|64|65|86)[D|C|F|M]?:)(.*)/
                      $2
                    else
                      line
                    end
        @current_line = "#{@current_line}#{@join_lines_by}#{next_line}"
      end
    rescue => e
      raise MT940Structured::InvalidFileContentError.new(e)
    end

    def end_bank_statement
      flush_line()
      @current_bank_statement.flush_transaction()
      @handler.end_bank_statement(@current_bank_statement.bank_statement) if @current_bank_statement.bank_statement
      @current_bank_statement.reset
    end

    def start_or_end_bank_statement(line)
      if line.match(/^:20:/)
        end_bank_statement
        @current_bank_statement.parse_line(line)
      end

      if line.match(/^:62(F|M):/)
        @current_bank_statement.parse_line(line)
        end_bank_statement
      end
    end
  end
end
