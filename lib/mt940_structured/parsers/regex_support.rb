module MT940Structured::Parsers
  module RegexSupport
    def self.regexify_keyword(string)
      /#{regexify_string(string)}/
    end

    def self.regexify_string(string)
      %Q{\/\s?#{string.scan(/.{1}/).join('\s?')}\s?\/}
    end
  end
end

