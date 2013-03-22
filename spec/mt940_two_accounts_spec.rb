require_relative 'spec_helper'

describe "two accounts" do
  before :each do
    @file_name = File.dirname(__FILE__) + '/fixtures/two_accounts.txt'
    @info = MT940::Base.parse_mt940(@file_name)
  end

  it 'have the correct number of bank accounts' do
    @info.size.should == 4
  end

  it 'have the opening balance of bank account' do
    @info["156750961"].opening_balance.should == 9265.12
    @info["156750961"].opening_date.should == Date.new(2012, 9, 17)
    @info["991430727"].opening_balance.should == 352.84
    @info["991430727"].opening_date.should == Date.new(2012, 10, 23)
    @info["3462483153"].opening_balance.should == 5000
    @info["3462483153"].opening_date.should == Date.new(2012, 11, 1)
    @info["132576155"].opening_balance.should == -12
    @info["132576155"].opening_date.should == Date.new(2012, 10, 26)
  end

  it 'have a closing balance of a bank account' do
    @info["156750961"].closing_balance.should == 2666.37
    @info["156750961"].closing_date.should == Date.new(2012, 9, 18)
    @info["991430727"].closing_balance.should == 352.84
    @info["991430727"].closing_date.should == Date.new(2012, 10, 24)
    @info["3462483153"].closing_balance.should == 5000
    @info["3462483153"].closing_date.should == Date.new(2012, 11, 1)
    @info["132576155"].closing_balance.should == 238
    @info["132576155"].closing_date.should == Date.new(2012, 10, 29)
  end

  it 'have the number of transactions of bank account' do
    @info["156750961"].transactions.size.should == 2
    @info["991430727"].transactions.size.should == 0
    @info["3462483153"].transactions.size.should == 0
    @info["132576155"].transactions.size.should == 1
  end
end
