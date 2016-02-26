require_relative 'spec_helper'

describe "Triodos" do

  context 'mt940' do
    before :each do
      @file_name = File.dirname(__FILE__) + '/fixtures/triodos.txt'
      @bank_statements = MT940Structured::Parser.parse_mt940(@file_name)["390123456"]
      @transactions = @bank_statements.flat_map(&:transactions)
      @transaction = @transactions.first
    end

    it 'have the correct number of transactions' do
      expect(@transactions.size).to eq(2)
    end

    it 'get the opening balance and date' do
      expect(@bank_statements.first.previous_balance.amount).to eq(4975.09)
      expect(@bank_statements.first.previous_balance.date).to eq(Date.new(2011, 1, 1))
    end

    it 'get the closing balance and date' do
      expect(@bank_statements.first.new_balance.amount).to eq(4370.79)
      expect(@bank_statements.first.new_balance.date).to eq(Date.new(2011, 2, 1))
    end

    context 'Transaction' do

      it 'have a bank_account' do
        expect(@transaction.bank_account).to eq('390123456')
      end

      it 'have an amount' do
        expect(@transaction.amount).to eq(-15.7)
      end

      it 'have a currency' do
        expect(@transaction.currency).to eq('EUR')
      end

      it 'have a description' do
        expect(@transaction.description).to eq('ALGEMENE TUSSENREKENING KOSTEN VAN 01-10-2010 TOT EN M ET 31-12-20100390123456')
      end

      it 'have a date' do
        expect(@transaction.date).to eq(Date.new(2011,1,1))
      end

      it 'return its bank' do
        expect(@transaction.bank).to eq('Triodos')
      end

      it 'return the contra_account' do
        expect(@transaction.contra_account).to eq('987654321')
      end

    end

  end

  context 'iban mt940' do
    before :each do
      @file_name = File.dirname(__FILE__) + '/fixtures/triodos_iban.txt'
      @bank_statements = MT940Structured::Parser.parse_mt940(@file_name)["454545454"]
      @transactions = @bank_statements.flat_map(&:transactions)
      @transaction = @transactions.first
    end

    it 'have the correct number of transactions' do
      expect(@transactions.size).to eq(3)
    end

    it 'get the opening balance and date' do
      expect(@bank_statements.first.previous_balance.amount).to eq(0)
      expect(@bank_statements.first.previous_balance.date).to eq(Date.new(2013, 10, 7))
    end

    it 'get the closing balance and date' do
      expect(@bank_statements.first.new_balance.amount).to eq(948)
      expect(@bank_statements.first.new_balance.date).to eq(Date.new(2013, 10, 25))
    end

    context 'iban transaction' do

      it 'have a bank_account' do
        expect(@transaction.bank_account).to eq('454545454')
      end

      it 'have an amount' do
        expect(@transaction.amount).to eq(1000)
      end

      it 'have a currency' do
        expect(@transaction.currency).to eq('EUR')
      end

      it 'have a description' do
        expect(@transaction.description).to eq('METSELAARBAASIK PAARDENA POSTBUS 969 8888BB UTRETRECH NEDERLAND STORTING AANDELENKAPITAAL ZAAK NR 40000')
      end

      it 'have a date' do
        expect(@transaction.date).to eq(Date.new(2013,10,7))
      end

      it 'has a bank' do
        expect(@transaction.bank).to eq('Triodos')
      end

      it 'has no contra account owner' do
        expect(@transaction.contra_account_owner).to be_nil
      end

      it 'has a contra_account iban' do
        expect(@transaction.contra_account_iban).to eq('NL12RABO0888888888')
      end

      it 'has a contra_account' do
        expect(@transaction.contra_account).to eq('888888888')
      end

    end

    context 'pin transactions' do
      let(:pin_transaction) {@transactions.last}
      it 'have a bank_account' do
        expect(pin_transaction.bank_account).to eq('454545454')
      end

      it 'have an amount' do
        expect(pin_transaction.amount).to eq(-10)
      end

      it 'have a currency' do
        expect(pin_transaction.currency).to eq('EUR')
      end

      it 'have a description' do
        expect(pin_transaction.description).to eq('NS-DKDKDKFJFJFLS 201 \KLKLKLFOOBAR \ BETAALAUTOMAAT 22- 09-14 12:00 PASNR. 009')
      end

      it 'have a date' do
        expect(pin_transaction.date).to eq(Date.new(2013,10,25))
      end

      it 'has a bank' do
        expect(pin_transaction.bank).to eq('Triodos')
      end

      it 'has no contra account owner' do
        expect(pin_transaction.contra_account_owner).to be_nil
      end

      it 'has no contra_account iban' do
        expect(pin_transaction.contra_account_iban).to be_nil
      end

      it 'has no contra_account' do
        expect(pin_transaction.contra_account).to be_nil
      end

    end


  end

end
