require_relative 'spec_helper'

describe "MT940::Base" do

  context 'classic mt940' do
    before :each do
      @file_name = File.dirname(__FILE__) + '/fixtures/abnamro.txt'
      @bank_statements = MT940Structured::Parser.parse_mt940(@file_name)["517852257"]
      @transactions = @bank_statements.flat_map(&:transactions)
      @transaction = @transactions.first
    end

    it 'have the correct number of transactions' do
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
  context 'sepa mt940' do
    before :each do
      @file_name = File.dirname(__FILE__) + '/fixtures/abnamro_structured.txt'
      @bank_statements = MT940::Base.parse_mt940(@file_name)["123212321"]
      @transactions = @bank_statements.flat_map(&:transactions)
    end

    it 'have the correct number of transactions' do
      @transactions.size.should == 10
    end

    it 'get the opening balance and date' do
      @bank_statements.first.previous_balance.amount.should == 10000.9
      @bank_statements.first.previous_balance.date.should == Date.new(2014, 1, 12)
    end

    it 'get the closing balance and date' do
      @bank_statements.last.new_balance.amount.should == 3976.9
      @bank_statements.last.new_balance.date.should == Date.new(2014, 1, 27)
    end

    context 'Transaction' do

      let(:transaction) { @transactions[1] }

      it 'have a bank_account' do
        transaction.bank_account.should == '123212321'
      end

      it 'have an amount' do
        transaction.amount.should == -10
      end

      it 'have the correct description in case of a regular bank' do
        transaction.description.should == 'BEA   NR:NND130   13.01.14/11.00 XXXXX 99 XXXXXX BV AMSTE,PAS123'
      end

      it 'have a date' do
        transaction.date.should == Date.new(2014, 1, 13)
      end

      it 'return its bank' do
        transaction.bank.should == 'Abnamro'
      end

      it 'have a currency' do
        transaction.currency.should == 'EUR'
      end

    end

    context 'sepa overboeking' do

      let(:transaction) { @transactions[2] }

      it 'have a bank_account' do
        transaction.bank_account.should == '123212321'
      end

      it 'have an amount' do
        transaction.amount.should == -10
      end

      it 'have the correct description in case of a regular bank' do
        transaction.description.should == "SAVINGS 3798473"
      end

      it 'have a date' do
        transaction.date.should == Date.new(2014, 1, 13)
      end

      it 'return its bank' do
        transaction.bank.should == 'Abnamro'
      end

      it 'have a currency' do
        transaction.currency.should == 'EUR'
      end

      it 'has a contra account' do
        transaction.contra_account.should == '987654321'
      end

      it 'has a contra account iban' do
        transaction.contra_account_iban.should == 'NL25ABNA0987654321'
      end

      it 'has a contra account owner' do
        transaction.contra_account_owner.should == 'FOOBAR'
      end
    end

    context 'sepa ideal' do
      let(:transaction) { @transactions[3] }

      it 'have a bank_account' do
        transaction.bank_account.should == '123212321'
      end

      it 'have an amount' do
        transaction.amount.should == -4
      end

      it 'have the correct description in case of a regular bank' do
        transaction.description.should == %Q{4851430136 0030000 735822580 NS E-TICKET(S)KENMERK: 26-01-2014 18:14 003000 0735822580}
      end

      it 'have a date' do
        transaction.date.should == Date.new(2014, 1, 26)
      end

      it 'return its bank' do
        transaction.bank.should == 'Abnamro'
      end

      it 'have a currency' do
        transaction.currency.should == 'EUR'
      end

      it 'has a contra account' do
        transaction.contra_account.should == '888888888'
      end

      it 'has a contra account iban' do
        transaction.contra_account_iban.should == 'NL70ABNA0888888888'
      end

      it 'has a contra account owner' do
        transaction.contra_account_owner.should == 'NS GROEP INZAKE NSR IDEA'
      end

    end

    context 'SEPA ACCEPTGIROBETALING' do
      let(:transaction) { @transactions[5] }

      it 'have a bank_account' do
        transaction.bank_account.should == '123212321'
      end

      it 'have an amount' do
        transaction.amount.should == -1000
      end

      it 'have the correct description in case of a regular bank' do
        transaction.description.should == %Q{BETALINGSKENM.: 1234567890098876 ID DEBITEUR: 777777777}
      end

      it 'have a date' do
        transaction.date.should == Date.new(2014, 1, 26)
      end

      it 'return its bank' do
        transaction.bank.should == 'Abnamro'
      end

      it 'have a currency' do
        transaction.currency.should == 'EUR'
      end

      it 'has a contra account' do
        transaction.contra_account.should == '2445588'
      end

      it 'has a contra account iban' do
        transaction.contra_account_iban.should == 'NL86INGB0002445588'
      end

      it 'has a contra account owner' do
        transaction.contra_account_owner.should == 'BELASTINGDIENST'
      end

    end
  end
end
