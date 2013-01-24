require 'helper'

class TestMt940Rabobank < Test::Unit::TestCase

  def setup
    @file_name = File.dirname(__FILE__) + '/fixtures/rabobank.txt'
    @transactions = MT940::Base.transactions(@file_name)
    @transaction = @transactions.first
  end

  should 'have the correct number of transactions' do
    assert_equal 3, @transactions.size
  end

  context 'Transaction' do
    should 'get the opening balance and date' do
      @info = MT940::Base.transactions_with_info(@file_name)

      assert_equal 473.17, @info.opening_balance
      assert_equal Date.new(2011, 6, 14), @info.opening_date
    end

    should 'get the debet opening balance and date' do
      @info = MT940::Base.transactions_with_info(File.dirname(__FILE__) + '/fixtures/rabobank_with_debet_opening_balance.txt')

      assert_equal -12, @info.opening_balance
      assert_equal Date.new(2012, 10, 4), @info.opening_date
      assert_not_nil @info.transactions
    end

    should 'have a bank_account' do
      assert_equal '129199348', @transaction.bank_account
    end

    context 'Contra account' do
      should 'be determined in case of a GIRO account' do
        assert_equal '121470966', @transaction.contra_account
      end

      should 'be determined in case of a regular bank' do
        assert_equal '733959555', @transactions[1].contra_account
      end

      should 'be determined in case of a NONREF' do
        assert_equal 'NONREF', @transactions.last.contra_account
      end
    end

    should 'have an amount' do
      assert_equal -1213.28, @transaction.amount
    end

    should 'have a currency' do
      assert_equal 'EUR', @transaction.currency
    end

    should 'have a contra_account_owner' do
      assert_equal 'W.P. Jansen', @transaction.contra_account_owner
    end

    should 'have a description' do
      assert_equal 'Terugboeking NIET AKKOORD MET AFSCHRIJVING KOSTEN KINDEROPVANG JUNI 20095731', @transaction.description
    end

    should 'have a date' do
      assert_equal Date.new(2011,5,27), @transaction.date
    end

    should 'return its bank' do
      assert_equal 'Rabobank', @transaction.bank
    end

  end

end
