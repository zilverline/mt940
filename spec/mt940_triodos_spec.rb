require_relative 'spec_helper'

describe "Triodos" do

  before :each do
    @file_name = File.dirname(__FILE__) + '/fixtures/triodos.txt'
    @bank_statements = MT940::Base.parse_mt940(@file_name)["390123456"]
    @transactions = @bank_statements.flat_map(&:transactions)
    @transaction = @transactions.first
  end
  
  it 'have the correct number of transactions' do
    @transactions.size.should == 2
  end

  it 'get the opening balance and date' do
    @bank_statements.first.previous_balance.amount.should ==4975.09
    @bank_statements.first.previous_balance.date.should == Date.new(2011, 1, 1)
  end

  it 'get the closing balance and date' do
    @bank_statements.first.new_balance.amount.should == 4370.79
    @bank_statements.first.new_balance.date.should == Date.new(2011, 2, 1)
  end

  context 'Transaction' do

    it 'have a bank_account' do
      @transaction.bank_account.should == '390123456'
    end

    it 'have an amount' do
      @transaction.amount.should == -15.7
    end

    it 'have a currency' do
      @transaction.currency.should == 'EUR'
    end

    it 'have a description' do
      @transaction.description.should == 'ALGEMENE TUSSENREKENING KOSTEN VAN 01-10-2010 TOT EN M ET 31-12-20100390123456'
    end

    it 'have a date' do
      @transaction.date.should == Date.new(2011,1,1)
    end

    it 'return its bank' do
      @transaction.bank.should == 'Triodos'
    end

    it 'return the contra_account' do
      @transaction.contra_account.should == '987654321'
    end

  end

end
