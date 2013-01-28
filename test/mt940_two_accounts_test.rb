require 'helper'

class TestMt940TwoAccounts < Test::Unit::TestCase
  def setup
    @file_name = File.dirname(__FILE__) + '/fixtures/two_accounts.txt'
    @info = MT940::Base.parse_mt940(@file_name)
  end

  should 'have the correct number of bank accounts' do
    assert_equal 4, @info.size
  end

  should 'have the opening balance of bank account' do
    assert_equal 9265.12, @info["156750961"].opening_balance
    assert_equal Date.new(2012, 9, 17), @info["156750961"].opening_date
    assert_equal 352.84, @info["991430727"].opening_balance
    assert_equal Date.new(2012, 10, 23), @info["991430727"].opening_date
    assert_equal 5000, @info["3462483153"].opening_balance
    assert_equal Date.new(2012, 11, 1), @info["3462483153"].opening_date
    assert_equal -12, @info["132576155"].opening_balance
    assert_equal Date.new(2012, 10, 26), @info["132576155"].opening_date
  end

  should 'have a closing balance of a bank account' do
    assert_equal 2666.37, @info["156750961"].closing_balance
    assert_equal Date.new(2012, 9, 18), @info["156750961"].closing_date
    assert_equal 352.84, @info["991430727"].closing_balance
    assert_equal Date.new(2012, 10, 24), @info["991430727"].closing_date
    assert_equal 5000, @info["3462483153"].closing_balance
    assert_equal Date.new(2012, 11, 1), @info["3462483153"].closing_date
    assert_equal 238, @info["132576155"].closing_balance
    assert_equal Date.new(2012, 10, 29), @info["132576155"].closing_date
  end

  should 'have the number of transactions of bank account' do
    assert_equal 2, @info["156750961"].transactions.size
    assert_equal 0, @info["991430727"].transactions.size
    assert_equal 0, @info["3462483153"].transactions.size
    assert_equal 1, @info["132576155"].transactions.size
  end
end
