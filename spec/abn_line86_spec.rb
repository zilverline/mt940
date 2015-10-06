require_relative 'spec_helper'

describe MT940Structured::Parsers::Abnamro::Line86 do
  let(:result) { MT940Structured::Parsers::Abnamro::Line86.parse line86 }

  context 'sepa overboeking' do
    let(:line86) { "/TRTP/SEPA OVERBOEKING/IBAN/NL57INGB0001212121/BIC/INGBNL2A/NAME/ CAFE MON AMI/REMI/897789005/EREF/NOTPROVIDED" }
    it 'gets the End to End Reference' do
      expect(result.eref).to eq 'NOTPROVIDED'
    end

    it 'gets the counter party' do
      expect(result.counter_party).to_not be_nil
      expect(result.counter_party.iban).to eq 'NL57INGB0001212121'
      expect(result.counter_party.bic).to eq 'INGBNL2A'
      expect(result.counter_party.name).to eq 'CAFE MON AMI'
      expect(result.counter_party.city).to be_nil
    end

    context 'spaces in keyword' do
      let(:line86) { '/ E R E F /400313131313' }
      it 'matches spaces' do
        expect(result.eref).to eq '400313131313'
      end
    end

    it 'gets the remittance info' do
      expect(result.remi).to eq '897789005'
    end
  end

  context 'sepa incasso algemeen doorlopend' do
    let(:line86) {'/TRTP/SEPA INCASSO ALGEMEEN DOORLOPEND/NAME/T-MOBILE NETHERLANDS BV/CSID/NL93ZZZ332656790051 /MARF/1.16677357/REMI/FACTUURNUMMER 102354687525/IBAN/NL57INGB0001212121/BIC/COBANL2XXXX/EREF/5036544 10899'}

    it 'gets the End to End Reference' do
      expect(result.eref).to eq '5036544 10899'
    end

    it 'gets the counter party' do
      expect(result.counter_party).to_not be_nil
      expect(result.counter_party.name).to eq 'T-MOBILE NETHERLANDS BV'
      expect(result.counter_party.iban).to eq 'NL57INGB0001212121'
      expect(result.counter_party.bic).to eq 'COBANL2XXXX'
      expect(result.counter_party.city).to be_nil
    end

    it 'gets the marf' do
      expect(result.marf).to eq '1.16677357'
    end

  end

end
