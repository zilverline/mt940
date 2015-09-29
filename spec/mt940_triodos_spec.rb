require_relative 'spec_helper'

describe "Triodos" do

  before :each do
    @file_name = File.dirname(__FILE__) + '/fixtures/triodos.txt'
    @bank_statements = MT940Structured::Parser.parse_mt940(@file_name)["390123456"]
    @transactions = @bank_statements.flat_map(&:transactions)
    @transaction = @transactions.first
  end
  
  it 'have the correct number of transactions' do
    expect(@transactions.size).to eq(2)
  end

  it 'get the opening balance and date' do
    expect(@bank_statements.first.previous_balance.amount).to eq(4975.09)
    expect(@bank_statements.first.previous_balance.date).to eq(Date.new(2011, 1, 1))
  end

  it 'get the closing balance and date' do
    expect(@bank_statements.first.new_balance.amount).to eq(4370.79)
    expect(@bank_statements.first.new_balance.date).to eq(Date.new(2011, 2, 1))
  end

  context 'Transaction' do

    it 'have a bank_account' do
      expect(@transaction.bank_account).to eq('390123456')
    end

    it 'have an amount' do
      expect(@transaction.amount).to eq(-15.7)
    end

    it 'have a currency' do
      expect(@transaction.currency).to eq('EUR')
    end

    it 'have a description' do
      expect(@transaction.description).to eq('ALGEMENE TUSSENREKENING KOSTEN VAN 01-10-2010 TOT EN M ET 31-12-20100390123456')
    end

    it 'have a date' do
      expect(@transaction.date).to eq(Date.new(2011,1,1))
    end

    it 'return its bank' do
      expect(@transaction.bank).to eq('Triodos')
    end

    it 'return the contra_account' do
      expect(@transaction.contra_account).to eq('987654321')
    end

  end

end
