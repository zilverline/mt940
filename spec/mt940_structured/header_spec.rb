require 'spec_helper'

describe MT940Structured::Header do

  subject { MT940Structured::Header.new(lines).parser }

  context "Rabobank" do
    let(:lines) { [":940:", ":20:940A121001", ":25:2121.21.211EUR"] }
    it { is_expected.to be_kind_of(MT940Structured::Parsers::Rabobank::Parser) }
  end

  context "ING" do
    let(:lines) { ["0000 01INGBNL2AXXXX00001", "0000 01INGBNL2AXXXX00001", "940 00", ":20:MPBZ", ":25:0001234567"] }
    it { is_expected.to be_kind_of(MT940Structured::Parsers::Ing::Parser) }
  end

  context "ABN Amro" do
    let(:lines) { ["ABNANL2A", "940", "ABNANL2A", ":20:ABN AMRO BANK NV", ":25:517852257"] }
    it { is_expected.to be_kind_of(MT940Structured::Parsers::Abnamro::Parser) }
  end

  context "Triodos bank" do
    let(:lines) { [":20:1308728725026/1", ":25:TRIODOSBANK/0390123456", ":28:1"] }
    it { is_expected.to be_kind_of(MT940Structured::Parsers::Triodos::Parser) }
  end

  context "Unknown bank" do
    let(:lines) { ["kjdshfgkljdsfg"] }
    it { expect { subject }.to raise_error(MT940Structured::UnsupportedBankError) }
  end

end
