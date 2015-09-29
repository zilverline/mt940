require_relative 'spec_helper'

describe "two accounts" do
  before :each do
    @file_name = File.dirname(__FILE__) + '/fixtures/two_accounts.txt'
    @bank_statements = MT940Structured::Parser.parse_mt940(@file_name)
  end

  it 'have the correct number of bank accounts' do
    expect(@bank_statements.size).to eq(4)
  end

  it 'have the opening balance of bank account' do
    expect(@bank_statements["156750961"].first.previous_balance.amount).to eq(9265.12)
    expect(@bank_statements["156750961"].first.previous_balance.date).to eq(Date.new(2012, 9, 17))

    expect(@bank_statements["991430727"].first.previous_balance.amount).to eq(352.84)
    expect(@bank_statements["991430727"].first.previous_balance.date).to eq(Date.new(2012, 10, 23))

    expect(@bank_statements["3462483153"].first.previous_balance.amount).to eq(5000)
    expect(@bank_statements["3462483153"].first.previous_balance.date).to eq(Date.new(2012, 11, 1))

    expect(@bank_statements["132576155"].first.previous_balance.amount).to eq(-12)
    expect(@bank_statements["132576155"].first.previous_balance.date).to eq(Date.new(2012, 10, 26))
  end

  it 'have a closing balance of a bank account' do
    expect(@bank_statements["156750961"].last.new_balance.amount).to eq(2666.37)
    expect(@bank_statements["156750961"].last.new_balance.date).to eq(Date.new(2012, 9, 18))

    expect(@bank_statements["991430727"].last.new_balance.amount).to eq(352.84)
    expect(@bank_statements["991430727"].last.new_balance.date).to eq(Date.new(2012, 10, 24))

    expect(@bank_statements["3462483153"].last.new_balance.amount).to eq(5000)
    expect(@bank_statements["3462483153"].last.new_balance.date).to eq(Date.new(2012, 11, 1))

    expect(@bank_statements["132576155"].last.new_balance.amount).to eq(238)
    expect(@bank_statements["132576155"].last.new_balance.date).to eq(Date.new(2012, 10, 29))
  end

  it 'have the number of transactions of bank account' do
    expect(@bank_statements["156750961"].flat_map(&:transactions).size).to eq(2)
    expect(@bank_statements["991430727"].flat_map(&:transactions).size).to eq(0)

    expect(@bank_statements["3462483153"].flat_map(&:transactions).size).to eq(0)
    expect(@bank_statements["132576155"].flat_map(&:transactions).size).to eq(1)
  end

end
