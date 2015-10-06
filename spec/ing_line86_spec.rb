require_relative 'spec_helper'

describe MT940Structured::Parsers::Ing::Line86 do
  let(:line86) { "/EREF/400313131313//MARF/2.34567890//CSID/NL11AAA441212121212 //CNTP/NL21BASN0272727272/COBANL2XXXX/T-Mobile Netherlands BV///R EMI/USTD//Factuurnummer 858585858585//PURP/OTHR/" }
  let(:result) { MT940Structured::Parsers::Ing::Line86.parse line86 }

  it 'gets the End to End Reference' do
    expect(result.eref).to eq '400313131313'
  end

  it 'gets the Mandate Reference' do
    expect(result.marf).to eq '2.34567890'
  end

  it 'gets the counter party' do
    expect(result.counter_party).to_not be_nil
    expect(result.counter_party.iban).to eq 'NL21BASN0272727272'
    expect(result.counter_party.bic).to eq 'COBANL2XXXX'
    expect(result.counter_party.name).to eq 'T-Mobile Netherlands BV'
    expect(result.counter_party.city).to be_nil
  end

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

  context 'dutch structured' do

    let(:line86) { '/EREF/400313131313//MARF/2.34567890//CSID/NL11AAA441212121212 //CNTP/NL21BASN0272727272/COBANL2XXXX/T-Mobile Netherlands BV///R EMI/STRD/CUR/1212121212//PURP/OTHR/' }

    it 'gets the remittance info' do
      expect(result.remi).to eq '1212121212'
    end

  end

  context 'iso structured' do

    let(:line86) { '/EREF/400313131313//MARF/2.34567890//CSID/NL11AAA441212121212 //CNTP/NL21BASN0272727272/COBANL2XXXX/T-Mobile Netherlands BV///R EMI/STRD/ISO/4444//PURP/OTHR/' }

    it 'gets the remittance info' do
      expect(result.remi).to eq '4444'
    end

  end

end
