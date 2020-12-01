require_relative 'spec_helper'

describe MT940Structured::Parsers::Generic::Line86 do
  let(:line86) { "/EREF/400313131313//MARF/2.34567890//CSID/NL11AAA441212121212 //CNTP/NL21BASN0272727272/COBANL2XXXX/T-Mobile Netherlands BV///R EMI/USTD//Factuurnummer 858585858585//PURP/OTHR/" }
  let(:result) { MT940Structured::Parsers::Generic }

  context 'spaces in keyword' do
    let(:line86) { '/ E R E F /400313131313//' }
    it 'matches spaces' do
      expect(result.eref).to eq '400313131313'
    end
  end

  context 'spaces in double slash' do
    let(:line86) { '/EREF/400313131313/ /' }
    it 'matches spaces' do
      expect(result.eref).to eq '400313131313'
    end
  end

  context 'ends with single slash' do
    let(:line86) { '/EREF/400313131313/' }

    it 'matches end of line' do
      expect(result.eref).to eq '400313131313'
    end
  end


  context 'unstructured remittance info' do

    it 'gets the remittance info' do
      expect(result.remi).to eq 'Factuurnummer 858585858585'
    end

  end

end
