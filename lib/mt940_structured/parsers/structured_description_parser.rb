module MT940Structured::Parsers
  module StructuredDescriptionParser
    def parse_description_after_tag(description_parts, tag, number_of_parts = 1)
      description_start_index = description_parts.index { |part| part == tag }
      if description_start_index and description_parts[description_start_index + number_of_parts]
        description_parts[description_start_index + number_of_parts].strip
      else
        ''
      end
    end
  end
end
