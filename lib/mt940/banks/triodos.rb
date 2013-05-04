class MT940::Triodos < MT940::Base

  def self.determine_bank(*args)
    self if args[0].match(/^:20:/) && args[1] && args[1].match(/^:25:TRIODOSBANK/)
  end

  def parse_tag_86
    if !@tag86 && @line.match(/^:86:\s?(.*)\Z/m)
      @tag86 = true
      temp_description = $1.gsub(/\n/, ' ').gsub(/>\d{2}/, '').strip
      if temp_description.match(/^\d+(\d{9})(.*)$/)
        @transaction.contra_account = $1.rjust(9, '000000000')
        @transaction.description = $2.strip
      else
        @transaction.description = temp_description
      end
    end
  end

end
