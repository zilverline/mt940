module MT940Structured::Parsers
  module StructuredDescriptionParser
    def parse_description_after_tag(description_parts, tag)
      description_start_index = description_parts.index { |part| part == tag }
      if description_start_index
        description_parts[description_start_index + 1].strip
      else
        ''
      end
    end
  end
end
