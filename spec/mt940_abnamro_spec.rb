require_relative 'spec_helper'

describe "MT940::Base" do
  
  before :each do
    @file_name = File.dirname(__FILE__) + '/fixtures/abnamro.txt'
    @bank_statements = MT940::Base.parse_mt940(@file_name)["517852257"]
    @transactions = @bank_statements.flat_map(&:transactions)
    @transaction = @transactions.first
  end

  it 'have the correct number of transactions', focus: true do
    @transactions.size.should == 10
  end

  it 'get the opening balance and date' do
    @bank_statements.first.previous_balance.amount.should == 3236.28
    @bank_statements.first.previous_balance.date.should == Date.new(2011, 5, 22)
  end

  it 'get the closing balance and date' do
    @bank_statements.last.new_balance.amount.should == 1849.75
    @bank_statements.last.new_balance.date.should == Date.new(2011, 5, 24)
  end

  context 'Transaction' do

    it 'have a bank_account' do
      @transaction.bank_account.should == '517852257'
    end

    it 'have an amount' do
      @transaction.amount.should == -9.00
    end

    context 'Description' do
      it 'have the correct description in case of a GIRO account' do
        @transaction.description.should == 'KPN - DIGITENNE    BETALINGSKENM.  000000042188659 5314606715                       BETREFT FACTUUR D.D. 20-05-2011 INCL. 1,44 BTW'
      end

      it 'have the correct description in case of a regular bank' do
        @transactions.last.description.should == 'MYCOM DEN HAAG  S-GRAVEN,PAS999'
      end
    end

    it 'have a date' do
      @transaction.date.should == Date.new(2011, 5, 24)
    end

    it 'return its bank' do
      @transaction.bank.should == 'Abnamro'
    end

    it 'have a currency' do
      @transaction.currency.should == 'EUR'
    end

    context 'Contra account' do
      it 'be determined in case of a GIRO account' do
        @transaction.contra_account.should == '000428428'
      end

      it 'be determined in case of a regular bank' do
        @transactions.last.contra_account.should == '528939882'
      end
    end
  end

end
