require_relative 'spec_helper'

describe "ING" do

  context 'old mt940' do
    before :each do
      @file_name = File.dirname(__FILE__) + '/fixtures/ing.txt'
      @bank_statements = MT940::Base.parse_mt940(@file_name)["1234567"]
      @transactions = @bank_statements.flat_map(&:transactions)
      @transaction = @transactions.first
    end

    it 'have the correct number of transactions' do
      @transactions.size.should == 6
    end

    it 'get the opening balance and date' do
      @bank_statements.first.previous_balance.amount.should == 0
      @bank_statements.first.previous_balance.date.should == Date.new(2010, 7, 22)
    end

    it 'get the closing balance and date' do
      @bank_statements.last.new_balance.amount.should == 3.47
      @bank_statements.last.new_balance.date.should == Date.new(2010, 7, 23)
    end

    context 'Transaction' do

      it 'have a bank_account' do
        @transaction.bank_account.should == '1234567'
      end

      it 'have an amount' do
        @transaction.amount.should == -25.03
      end

      it 'have a currency' do
        @transaction.currency.should == 'EUR'
      end

      it 'have a date' do
        @transaction.date.should == Date.new(2010, 7, 22)
      end

      it 'return its bank' do
        @transaction.bank.should == 'Ing'
      end

      it "should return the type" do
        @transaction.type.should == 'Overschrijving'
      end

      it 'have a description' do
        @transactions.last.description.should == 'EJ46GREENP100610T1456 CLIEOP TMG GPHONGKONG AMSTERDAM'
      end

      it 'return the contra_account' do
        @transactions.last.contra_account.should == 'NONREF'
      end

    end

  end

  context 'new mt940' do

    before :each do
      @file_name = File.dirname(__FILE__) + '/fixtures/ing_structured.txt'
      @bank_statements = MT940::Base.parse_mt940(@file_name)["1234567"]
      @transactions = @bank_statements.flat_map(&:transactions)
      @transaction = @transactions.first
    end

    it 'has the correct number of transactions' do
      @transactions.size.should == 7
    end

    it 'get the opening balance and date' do
      @bank_statements.first.previous_balance.amount.should == 500
      @bank_statements.first.previous_balance.date.should == Date.new(2013, 6, 30)
    end

    it 'get the closing balance and date' do
      @bank_statements.last.new_balance.amount.should == 400
      @bank_statements.last.new_balance.date.should == Date.new(2013, 10, 1)
    end

    context 'Transaction' do
      before :each do
        @transaction = @transactions[1]
      end

      it 'have a bank_account' do
        @transaction.bank_account.should == '1234567'
      end

      it 'have an amount' do
        @transaction.amount.should == 300
      end

      it 'have a currency' do
        @transaction.currency.should == 'EUR'
      end

      it 'have a date' do
        @transaction.date.should == Date.new(2013, 7, 1)
      end

      it 'return its bank' do
        @transaction.bank.should == 'Ing'
      end

      it "should return the type" do
        @transaction.type.should == 'Overschrijving'
      end

      it 'have a description' do
        @transaction.description.should == 'VAN Zkl Kwartaal Spaarrekening'
      end

      it 'return the contra_account' do
        @transaction.contra_account.should == '1234567'
      end

    end

    context 'IBAN transaction' do
      before :each do
        @transaction = @transactions[2]
      end

      it 'have a bank_account' do
        @transaction.bank_account.should == '1234567'
      end

      it 'have an amount' do
        @transaction.amount.should == -400
      end

      it 'have a currency' do
        @transaction.currency.should == 'EUR'
      end

      it 'have a date' do
        @transaction.date.should == Date.new(2013, 7, 1)
      end

      it 'return its bank' do
        @transaction.bank.should == 'Ing'
      end

      it "should return the type" do
        @transaction.type.should == 'Internetbankieren'
      end

      it 'have a description' do
        @transaction.description.should == 'kilometervergoed ing 2e kwartaal 2013'
      end

      it 'returns the contra_account' do
        @transaction.contra_account.should == '987654321'
        @transaction.contra_account_iban.should == 'NL57ABNA0987654321'
        @transaction.contra_account_owner.should == 'J AAP'
      end

    end

    context 'IBAN transaction from tax' do
      before :each do
        @transaction = @transactions[4]
      end

      it 'have a description' do
        @transaction.description.should == 'BELASTINGDIENST BTW 2e kwartaal 2013 SCOR/CUR/8850426741301240'
      end

      it 'has an account and iban' do
        @transaction.contra_account.should == '2445588'
        @transaction.contra_account_iban.should == 'NL86INGB0002445588'
      end

      it 'is unable to parse the contra account owner' do

        @transaction.contra_account_owner.should be_nil
      end
    end

    context 'IBAN transaction with EREF NOTPROVIDED' do
      before :each do
        @transaction = @transactions[3]
      end

      it 'have a description' do
        @transaction.description.should == 'parkeren'
      end

      it 'has an account and iban' do
        @transaction.contra_account.should == '987654321'
        @transaction.contra_account_iban.should == 'NL57ABNA0987654321'
      end

      it 'has a contra account owner' do
        @transaction.contra_account_owner.should == 'J AAP / FOO B.V.'
      end

    end

    context 'IBAN transaction with EREF' do
      before :each do
        @transaction = @transactions.last
      end

      it 'have a description' do
        @transaction.description.should == 'J AAP kilometervergoeding 3e kwart aal'
      end

      it 'has an account and iban' do
        @transaction.contra_account.should == '987654321'
        @transaction.contra_account_iban.should == 'NL57ABNA0987654321'
      end

      it 'is unable to parse the contra account owner' do
        @transaction.contra_account_owner.should be_nil
      end
    end
  end

  context 'europese incasso' do
    before :each do
      @file_name = File.dirname(__FILE__) + '/fixtures/ing/eu_incasso.txt'
      @bank_statements = MT940::Base.parse_mt940(@file_name)["1234567"]
      @transactions = @bank_statements.flat_map(&:transactions)
      @transaction = @transactions.first
    end

    it 'has a description' do
      @transaction.description.should == 'NL10XXX100020000000 0100000000000 000000000000-AAAA12345678 Premie xxxxxxxxxxxxxxxxxxxxxxx'
    end

    it 'has a contra account' do
      @transaction.contra_account.should == "3000"
    end

    it 'has a contra account iban' do
      @transaction.contra_account_iban.should == "NL58INGB0000003000"
    end

    it 'has a contra account owner' do
      @transaction.contra_account_owner.should == "JAAPJAAP  FIETS PAPIER QWDFDFGGASDFGDSFGS NV"
    end
  end

  context 'foreign transaction' do
    before :each do
      @file_name = File.dirname(__FILE__) + '/fixtures/ing/eu_incasso_foreign_transaction.txt'
      @bank_statements = MT940::Base.parse_mt940(@file_name)["1234567"]
      @transactions = @bank_statements.flat_map(&:transactions)
      @transaction = @transactions.first
    end

    it 'has a description' do
      @transaction.description.should == 'GB40G01SDDCITI00000011091334 9087653421 NL0001MKXD ADWORDS:3455667788:NL0001MKXD'
    end

    it 'has a contra account' do
      @transaction.contra_account.should == "BB123456789876567898"
    end

    it 'has a contra account iban' do
      @transaction.contra_account_iban.should == "BB123456789876567898"
    end

    it 'has a contra account owner' do
      @transaction.contra_account_owner.should == "Google  Ireland Limited"
    end
  end

  pending 'new line in reference after company name' do
    before :each do
      @file_name = File.dirname(__FILE__) + '/fixtures/ing/failing.txt'
      @bank_statements = MT940::Base.parse_mt940(@file_name)["1234567"]
      @transactions = @bank_statements.flat_map(&:transactions)
      @transaction = @transactions.first
    end

    it 'has a description' do
      @transaction.description.should == 'GB40G01SDDCITI00000011091334 9087653421 NL0001MKXD ADWORDS:3455667788:NL0001MKXD'
    end

    it 'has a contra account' do
      @transaction.contra_account.should == "BB123456789876567898"
    end

    it 'has a contra account iban' do
      @transaction.contra_account_iban.should == "BB123456789876567898"
    end

    it 'has a contra account owner' do
      @transaction.contra_account_owner.should == "Google  Ireland Limited"
    end

  end
end
