require 'spec_helper'

describe MT940Structured::Parser do
  let(:file_name) { File.dirname(__FILE__) + '/../fixtures/logo.bmp' }

  it 'fails when file is not an mt940 at all' do
    expect {MT940Structured::Parser.parse_mt940(file_name)}.to raise_error(MT940Structured::InvalidFileContentError)
  end
end
