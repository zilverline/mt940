require_relative 'spec_helper'

describe MT940Structured::FileContent do

  subject { MT940Structured::FileContent.new(raw_lines).group_lines }

  context "ignores all lines up to :20:" do
    let(:raw_lines) { [":940:", ":20:940A121001", ":86:2121.21.211EUR"] }
    its(:size) { should eq 2 }
    its(:first) { should eq ":20:940A121001" }
    its(:last) { should eq ":86:2121.21.211EUR" }
  end

  context "two :86: lines" do
    let(:raw_lines) { [":20:940A121001", ":86:2121.21.211EUR", "belongs to first :86:", ":61:bla"] }
    it "groups them" do
      expect(subject[1]).to eq(":86:2121.21.211EUR belongs to first :86:")
    end

    its(:last) { should eq ":61:bla" }
  end

  context "multiple :86: lines" do
    let(:raw_lines) { [":20:940A121001", ":86:2121.21.211EUR", "belongs to first :86:", "also belongs to first :86:", ":61:bla"] }
    it "groups them" do
      expect(subject[1]).to eq(":86:2121.21.211EUR belongs to first :86: also belongs to first :86:")
    end

    its(:last) { should eq ":61:bla" }
  end

  context "stops at end of file character for ING" do
    let(:raw_lines) { [":20:940A121001", ":86:2121.21.211EUR", "-XXX"] }
    its(:last) { should eq ":86:2121.21.211EUR" }
  end

  context "stops at end of file character for Rabobank" do
    let(:raw_lines) { [":20:940A121001", ":86:2121.21.211EUR", ":62F:C121031EUR000000006675,99"] }
    its(:last) { should eq ":62F:C121031EUR000000006675,99" }
  end

  context "stops at end of file character for Abn Amro" do
    let(:raw_lines) { [":20:940A121001", ":86:2121.21.211EUR", "-"] }
    its(:last) { should eq ":86:2121.21.211EUR" }
  end

end
