require_relative 'spec_helper'

describe "two accounts" do
  before :each do
    @file_name = File.dirname(__FILE__) + '/fixtures/two_accounts.txt'
    @bank_statements = MT940::Base.parse_mt940(@file_name)
  end

  it 'have the correct number of bank accounts' do
    @bank_statements.size.should == 4
  end

  it 'have the opening balance of bank account' do
    @bank_statements["156750961"].first.previous_balance.amount.should == 9265.12
    @bank_statements["156750961"].first.previous_balance.date.should == Date.new(2012, 9, 17)

    @bank_statements["991430727"].first.previous_balance.amount.should == 352.84
    @bank_statements["991430727"].first.previous_balance.date.should == Date.new(2012, 10, 23)

    @bank_statements["3462483153"].first.previous_balance.amount.should == 5000
    @bank_statements["3462483153"].first.previous_balance.date.should == Date.new(2012, 11, 1)

    @bank_statements["132576155"].first.previous_balance.amount.should == -12
    @bank_statements["132576155"].first.previous_balance.date.should == Date.new(2012, 10, 26)
  end

  it 'have a closing balance of a bank account' do
    @bank_statements["156750961"].last.new_balance.amount.should == 2666.37
    @bank_statements["156750961"].last.new_balance.date.should == Date.new(2012, 9, 18)

    @bank_statements["991430727"].last.new_balance.amount.should == 352.84
    @bank_statements["991430727"].last.new_balance.date.should == Date.new(2012, 10, 24)

    @bank_statements["3462483153"].last.new_balance.amount.should == 5000
    @bank_statements["3462483153"].last.new_balance.date.should == Date.new(2012, 11, 1)

    @bank_statements["132576155"].last.new_balance.amount.should == 238
    @bank_statements["132576155"].last.new_balance.date.should == Date.new(2012, 10, 29)
  end

  it 'have the number of transactions of bank account' do
    @bank_statements["156750961"].flat_map(&:transactions).size.should == 2
    @bank_statements["991430727"].flat_map(&:transactions).size.should == 0

    @bank_statements["3462483153"].flat_map(&:transactions).size.should == 0
    @bank_statements["132576155"].flat_map(&:transactions).size.should == 1
  end

end
