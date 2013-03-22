require_relative 'spec_helper'

describe "Rabobank" do

  before :each do
    @file_name = File.dirname(__FILE__) + '/fixtures/rabobank.txt'
    @info = MT940::Base.parse_mt940(@file_name)["129199348"]
    @transactions = @info.transactions
    @transaction = @transactions.first
  end

  it 'have the correct number of transactions' do
    @transactions.size.should == 3
  end

  it 'get the opening balance and date' do
    @info.opening_balance.should == 473.17
    @info.opening_date.should ==Date.new(2011, 6, 14)
  end

  it 'get the closing balance and date' do
    @info.closing_balance.should ==1250.87
    @info.closing_date.should ==Date.new(2011, 6, 17)
  end

  it 'get the debet opening balance and date' do
    @info = MT940::Base.parse_mt940(File.dirname(__FILE__) + '/fixtures/rabobank_with_debet_opening_balance.txt')["129199348"]
    @info.opening_balance.should ==-12
    @info.opening_date.should ==Date.new(2012, 10, 4)
    @info.transactions.should_not be_nil
  end

  context 'Transaction' do

    it 'have a bank_account' do
      @transaction.bank_account.should == '129199348'
    end

    context 'Contra account' do
      it 'be determined in case of a GIRO account' do
        @transaction.contra_account.should == '121470966'
      end

      it 'be determined in case of a regular bank' do
        @transactions[1].contra_account.should == '733959555'
      end

      it 'be determined in case of a NONREF' do
        @transactions.last.contra_account.should == 'NONREF'
      end
    end

    it 'have an amount' do
      @transaction.amount.should == -1213.28
    end

    it 'have a currency' do
      @transaction.currency.should == 'EUR'
    end

    it 'have a contra_account_owner' do
      @transaction.contra_account_owner.should == 'W.P. Jansen'
    end

    it 'have a description' do
      @transaction.description.should == 'Terugboeking NIET AKKOORD MET AFSCHRIJVING KOSTEN KINDEROPVANG JUNI 20095731'
    end

    it 'have a date' do
      @transaction.date.should == Date.new(2011, 5, 27)
    end

    it 'return its bank' do
      @transaction.bank.should =='Rabobank'
    end

  end

end
