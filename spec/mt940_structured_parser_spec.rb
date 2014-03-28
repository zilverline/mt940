require_relative 'spec_helper'

describe MT940Structured::Parser do
  let(:file_path) { File.dirname(__FILE__) + '/fixtures/rabobank_mt940_structured.txt' }

  subject { MT940Structured::Parser.parse_mt940(file_path) }

  it { should be_kind_of(Hash) }

end
