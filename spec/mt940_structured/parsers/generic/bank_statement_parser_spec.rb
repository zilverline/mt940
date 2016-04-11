require 'spec_helper'

describe MT940Structured::Parsers::BankStatementParser do

  let(:transaction_parsers) { MT940Structured::Parsers::Generic::TransactionParsers.new }
  subject { MT940Structured::Parsers::BankStatementParser.new("Generic", transaction_parsers, lines).bank_statement }

  context "structured" do
    let(:lines) do
      [
          ":25:GARETH",
          ":28C:160/1",
          ":60F:C130402EUR000000001147,95",
          ":61:130403D000000000127,50N102NONREF TEST SAMPLE",
          ":61:091211DR000000000002,50N001NONREF",
          ":86:/EREF/02-04-2013 22:56 1120000153447185/BENM//NAME/Nespresso Nede rland B.V./REMI/674725433 1120000153447185 14144467636004962 /ISDT/2013-04-03",
          ":62F:C130404EUR000000018846,34"
      ]
    end

    it { is_expected.to be_kind_of(MT940::BankStatement) }

    it 'has NONREF as customer' do
      expect(subject.transactions.first.customer_reference).to eq('NONREF')
    end

    it 'has TEST REF as customer ref' do
    	expect(subject.transactions.first.bank_reference).to eq('TEST SAMPLE')
    end
	it 'has TEST REF as customer ref when no ref there' do
    	expect(subject.transactions.last.bank_reference).to eq('')
    end
  end


end
