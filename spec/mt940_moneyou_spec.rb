require_relative 'spec_helper'

describe MT940Structured::Parser do


  before :each do
    @file_name = File.dirname(__FILE__) + "/fixtures/abn/#{file_name}"
    @bank_statements = MT940Structured::Parser.parse_mt940(@file_name)[bank_account_number]
    @transactions = @bank_statements.flat_map(&:transactions)
    @transaction = @transactions.first
  end
  context 'classic mt940' do
    let(:file_name) { 'moneyou.txt' }
    let(:bank_account_number) { '987654321' }

    it 'have the correct number of transactions' do
      expect(@transactions.size).to eq(2)
    end

    it 'get the opening balance and date' do
      expect(@bank_statements.first.previous_balance.amount).to eq(43119.71)
      expect(@bank_statements.first.previous_balance.date).to eq(Date.new(2018, 12, 31))
    end

    it 'get the closing balance and date' do
      expect(@bank_statements.last.new_balance.amount).to eq(43131.47)
      expect(@bank_statements.last.new_balance.date).to eq(Date.new(2019, 3, 29))
    end

    context 'Transaction' do

      it 'have a bank_account' do
        expect(@transaction.bank_account).to eq('987654321')
      end

      it 'have an amount' do
        expect(@transaction.amount).to eq(6.44)
      end

      it 'have the correct description in case of a GIRO account' do
        expect(@transaction.description).to eq('ONTVANGEN RENTE')
      end

      it 'have a date' do
        expect(@transaction.date).to eq(Date.new(2019, 1, 1))
      end

      it 'return its bank' do
        expect(@transaction.bank).to eq('Moneyou')
      end

      it 'have a currency' do
        expect(@transaction.currency).to eq('EUR')
      end

      it 'has a contra account' do
        expect(@transaction.contra_account).to eq('NONREF')
      end

    end
  end
end
