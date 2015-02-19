require_relative 'spec_helper'

describe "Deutsche Bank" do

  before :all do
    @file_name       = File.dirname(__FILE__) + '/fixtures/deutsche_bank.txt'
    @bank_statements = MT940Structured::Parser.parse_mt940(@file_name, "\n")["40069462"]
    @transactions    = @bank_statements.flat_map(&:transactions)
    @credit_transfer = @transactions[0]
    @direct_debit    = @transactions[1]
  end

  it 'have the correct number of transactions' do
    expect(@transactions.size).to eq 2
  end

  context 'Credit-Transfer Transaction' do

    it 'have a customer reference' do
      expect(@credit_transfer.customer_reference).to eq 'NONREF'
    end

    it 'have a bank reference' do
      expect(@credit_transfer.bank_reference).to eq '8848037917407749'
    end

    it 'have a type' do
      expect(@credit_transfer.type).to eq 'SEPA-GUTSCHRIFT'
      expect(@credit_transfer.sepa_business_code).to eq '166'
    end

    it 'have a bank_account' do
      expect(@credit_transfer.bank_account).to eq '40069462'
    end

    it 'have an amount' do
      expect(@credit_transfer.amount).to eq 3.99
    end

    it 'have a currency' do
      expect(@credit_transfer.currency).to eq 'EUR'
    end

    it 'have a description' do
      expect(@credit_transfer.description).to eq 'EREF+NOTPROVIDEDSVWZ+DE38XXZ76536723768 335'
    end

    it 'have a value date' do
      expect(@credit_transfer.date).to eq Date.new(2014, 3, 25)
    end

    it 'have a accounting date' do
      expect(@credit_transfer.date_accounting).to eq Date.new(2014, 3, 26)
    end

    it 'return its bank' do
      expect(@credit_transfer.bank).to eq 'Deutsche Bank'
    end

    it 'return the contra_account holder' do
      expect(@credit_transfer.contra_account_owner).to eq 'PETRA TESTER'
    end

    it 'return the contra_account iban' do
      expect(@credit_transfer.contra_account_iban).to eq 'DE422938944551657098369'
    end

    it 'return the contra_account bic' do
      expect(@credit_transfer.contra_bic).to eq 'GENODE61KA1'
    end

  end

  context 'Direct-Debit Transaction' do

    it 'have a type' do
      expect(@direct_debit.type).to eq 'SEPA-LASTSCHRIFT EINR.'
      expect(@direct_debit.sepa_business_code).to eq '171'
    end

    it 'have a bank_account' do
      expect(@direct_debit.bank_account).to eq '40069462'
    end

    it 'have an amount' do
      expect(@direct_debit.amount).to eq 0.01
    end

    it 'have a currency' do
      expect(@direct_debit.currency).to eq 'EUR'
    end

    it 'have a description' do
      expect(@direct_debit.description).to eq 'EREF+D979899680037A3DFA78E4KREF+43478SVWZ+7458.6345.6353 SEPA-DIRECT-DEBIT-DT.-BANK-1 HALLOWELT.IHRE REFERENZ: 766413'
    end

    it 'have a value date' do
      expect(@direct_debit.date).to eq Date.new(2014, 3, 28)
    end

    it 'have a accounting date' do
      expect(@direct_debit.date_accounting).to eq @direct_debit.date
    end

    it 'return its bank' do
      expect(@direct_debit.bank).to eq 'Deutsche Bank'
    end

    it 'return the contra_account holder' do
      expect(@direct_debit.contra_account_owner).to eq 'PETER TESTER'
    end

    it 'return the contra_account iban' do
      expect(@direct_debit.contra_account_iban).to eq 'DE04400694620000233025'
    end

    it 'return the contra_account bic' do
      expect(@direct_debit.contra_bic).to eq 'GENODEM1MSS'
    end

  end

end