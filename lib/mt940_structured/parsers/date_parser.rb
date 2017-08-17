module MT940Structured::Parsers
  module DateParser
    def parse_date(string)
    	## adding a short term hack here
    	## at the minute the system can't deal with weekend transactions
    	## this will have to change
    	## as a short term fix  I'm going to move weekend transactions to monday
      Date.new(2000 + string[0..1].to_i, string[2..3].to_i, string[4..5].to_i) if string
      # if string
      # 	d = Date.new(2000 + string[0..1].to_i, string[2..3].to_i, string[4..5].to_i)
      # 	(d.saturday?) ? d + 2 : (d.sunday?) ? d + 1 : d
      # end
    end
  end
end
