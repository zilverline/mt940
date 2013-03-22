require_relative 'spec_helper'

describe "ING" do

  before :each do
    @file_name = File.dirname(__FILE__) + '/fixtures/ing.txt'
    @info = MT940::Base.parse_mt940(@file_name)["001234567"]
    @transactions = @info.transactions
    @transaction = @transactions.first
  end
  
  it 'have the correct number of transactions' do
    @transactions.size.should == 6
  end

  it 'get the opening balance and date' do
    @info.opening_balance.should == 0
    @info.opening_date.should == Date.new(2010, 7, 22)
  end

  it 'get the closing balance and date' do
    @info.closing_balance.should == 3.47
    @info.closing_date.should == Date.new(2010, 7, 23)
  end

  context 'Transaction' do

    it 'have a bank_account' do
      @transaction.bank_account.should == '001234567'
    end

    it 'have an amount' do
      @transaction.amount.should == -25.03
    end

    it 'have a currency' do
      @transaction.currency.should == 'EUR'
    end

    it 'have a date' do
      @transaction.date.should == Date.new(2010,7,22)
    end

    it 'return its bank' do
      @transaction.bank.should == 'Ing'
    end

    it "should return the type" do
      @transaction.type.should == 'Overschrijving'
    end

    it 'have a description' do
      @transactions.last.description.should == 'EJ46GREENP100610T1456 CLIEOP TMG GPHONGKONG AMSTERDAM'
    end

    it 'return the contra_account' do
      @transactions.last.contra_account.should == '123456789'
    end

  end

end
