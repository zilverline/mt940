require 'helper'

class TestMt940Ing < Test::Unit::TestCase

  def setup
    @file_name = File.dirname(__FILE__) + '/fixtures/ing.txt'
    @info = MT940::Base.parse_mt940(@file_name)["001234567"]
    @transactions = @info.transactions
    @transaction = @transactions.first
  end
  
  should 'have the correct number of transactions' do
    assert_equal 6, @transactions.size
  end

  should 'get the opening balance and date' do
    assert_equal 0, @info.opening_balance
    assert_equal Date.new(2010, 7, 22), @info.opening_date
  end

  should 'get the closing balance and date' do
    assert_equal 3.47, @info.closing_balance
    assert_equal Date.new(2010, 7, 23), @info.closing_date
  end

  context 'Transaction' do

    should 'have a bank_account' do
      assert_equal '001234567', @transaction.bank_account
    end

    should 'have an amount' do
      assert_equal -25.03, @transaction.amount
    end

    should 'have a currency' do
      assert_equal 'EUR', @transaction.currency
    end

    should 'have a date' do
      assert_equal Date.new(2010,7,22), @transaction.date
    end

    should 'return its bank' do
      assert_equal 'Ing', @transaction.bank
    end

    should 'have a description' do
      assert_equal 'EJ46GREENP100610T1456 CLIEOP TMG GPHONGKONG AMSTERDAM', @transactions.last.description
    end

    should 'return the contra_account' do
      assert_equal '123456789', @transactions.last.contra_account
    end

  end

end
