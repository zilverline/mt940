require_relative 'spec_helper'

describe "ING" do

  context 'old mt940' do
    before :each do
      @file_name = File.dirname(__FILE__) + '/fixtures/ing.txt'
      @bank_statements = MT940Structured::Parser.parse_mt940(@file_name)["1234567"]
      @transactions = @bank_statements.flat_map(&:transactions)
      @transaction = @transactions.first
    end

    it 'have the correct number of transactions' do
      expect(@transactions.size).to eq(6)
    end

    it 'get the opening balance and date' do
      expect(@bank_statements.first.previous_balance.amount).to eq(0)
      expect(@bank_statements.first.previous_balance.date).to eq(Date.new(2010, 7, 22))
    end

    it 'get the closing balance and date' do
      expect(@bank_statements.last.new_balance.amount).to eq(3.47)
      expect(@bank_statements.last.new_balance.date).to eq(Date.new(2010, 7, 23))
    end

    context 'Transaction' do

      it 'have a bank_account' do
        expect(@transaction.bank_account).to eq('1234567')
      end

      it 'have an amount' do
        expect(@transaction.amount).to eq(-25.03)
      end

      it 'have a currency' do
        expect(@transaction.currency).to eq('EUR')
      end

      it 'have a date' do
        expect(@transaction.date).to eq(Date.new(2010, 7, 22))
      end

      it 'return its bank' do
        expect(@transaction.bank).to eq('Ing')
      end

      it "should return the type" do
        expect(@transaction.type).to eq('Overschrijving')
      end

      it 'have a description' do
        expect(@transactions.last.description).to eq('EJ46GREENP100610T1456 CLIEOP TMG GPHONGKONG AMSTERDAM')
      end

      it 'return the contra_account' do
        expect(@transactions.last.contra_account).to eq('NONREF')
      end

    end

  end

  context 'new mt940' do

    before :each do
      @file_name = File.dirname(__FILE__) + '/fixtures/ing_structured.txt'
      @bank_statements = MT940Structured::Parser.parse_mt940(@file_name)["1234567"]
      @transactions = @bank_statements.flat_map(&:transactions)
      @transaction = @transactions.first
    end

    it 'has the correct number of transactions' do
      expect(@transactions.size).to eq(7)
    end

    it 'get the opening balance and date' do
      expect(@bank_statements.first.previous_balance.amount).to eq(500)
      expect(@bank_statements.first.previous_balance.date).to eq(Date.new(2013, 6, 30))
    end

    it 'get the closing balance and date' do
      expect(@bank_statements.last.new_balance.amount).to eq(400)
      expect(@bank_statements.last.new_balance.date).to eq(Date.new(2013, 10, 1))
    end

    context 'Transaction' do
      before :each do
        @transaction = @transactions[1]
      end

      it 'have a bank_account' do
        expect(@transaction.bank_account).to eq('1234567')
      end

      it 'have an amount' do
        expect(@transaction.amount).to eq(300)
      end

      it 'have a currency' do
        expect(@transaction.currency).to eq('EUR')
      end

      it 'have a date' do
        expect(@transaction.date).to eq(Date.new(2013, 7, 1))
      end

      it 'return its bank' do
        expect(@transaction.bank).to eq('Ing')
      end

      it "should return the type" do
        expect(@transaction.type).to eq('Overschrijving')
      end

      it 'have a description' do
        expect(@transaction.description).to eq('VAN Zkl Kwartaal Spaarrekening')
      end

      it 'return the contra_account' do
        expect(@transaction.contra_account).to eq('1234567')
      end

    end

    context 'IBAN transaction' do
      before :each do
        @transaction = @transactions[2]
      end

      it 'have a bank_account' do
        expect(@transaction.bank_account).to eq('1234567')
      end

      it 'have an amount' do
        expect(@transaction.amount).to eq(-400)
      end

      it 'have a currency' do
        expect(@transaction.currency).to eq('EUR')
      end

      it 'have a date' do
        expect(@transaction.date).to eq(Date.new(2013, 7, 1))
      end

      it 'return its bank' do
        expect(@transaction.bank).to eq('Ing')
      end

      it "should return the type" do
        expect(@transaction.type).to eq('Internetbankieren')
      end

      it 'have a description' do
        expect(@transaction.description).to eq('kilometervergoed ing 2e kwartaal 2013')
      end

      it 'returns the contra_account' do
        expect(@transaction.contra_account).to eq('987654321')
        expect(@transaction.contra_account_iban).to eq('NL57ABNA0987654321')
        expect(@transaction.contra_account_owner).to eq('J AAP')
      end

    end

    context 'IBAN transaction from tax' do
      before :each do
        @transaction = @transactions[4]
      end

      it 'have a description' do
        expect(@transaction.description).to eq('BELASTINGDIENST BTW 2e kwartaal 2013 SCOR/CUR/8850426741301240')
      end

      it 'has an account and iban' do
        expect(@transaction.contra_account).to eq('2445588')
        expect(@transaction.contra_account_iban).to eq('NL86INGB0002445588')
      end

      it 'is unable to parse the contra account owner' do

        expect(@transaction.contra_account_owner).to be_nil
      end
    end

    context 'IBAN transaction with EREF NOTPROVIDED' do
      before :each do
        @transaction = @transactions[3]
      end

      it 'have a description' do
        expect(@transaction.description).to eq('parkeren')
      end

      it 'has an account and iban' do
        expect(@transaction.contra_account).to eq('987654321')
        expect(@transaction.contra_account_iban).to eq('NL57ABNA0987654321')
      end

      it 'has a contra account owner' do
        expect(@transaction.contra_account_owner).to eq('J AAP / FOO B.V.')
      end

    end

    context 'IBAN transaction with EREF' do
      before :each do
        @transaction = @transactions.last
      end

      it 'have a description' do
        expect(@transaction.description).to eq('J AAP kilometervergoeding 3e kwart aal')
      end

      it 'has an account and iban' do
        expect(@transaction.contra_account).to eq('987654321')
        expect(@transaction.contra_account_iban).to eq('NL57ABNA0987654321')
      end

      it 'is unable to parse the contra account owner' do
        expect(@transaction.contra_account_owner).to be_nil
      end
    end
  end

  context 'europese incasso' do
    before :each do
      @file_name = File.dirname(__FILE__) + '/fixtures/ing/eu_incasso.txt'
      @bank_statements = MT940Structured::Parser.parse_mt940(@file_name)["1234567"]
      @transactions = @bank_statements.flat_map(&:transactions)
      @transaction = @transactions.first
    end

    it 'has a description' do
      expect(@transaction.description).to eq('NL10XXX100020000000 01000 00000000 000000000000-AAAA12345678 Premie xxxxxxxxxxxxxxxxxxxxxxx')
    end

    it 'has a contra account' do
      expect(@transaction.contra_account).to eq("3000")
    end

    it 'has a contra account iban' do
      expect(@transaction.contra_account_iban).to eq("NL58INGB0000003000")
    end

    it 'has a contra account owner' do
      expect(@transaction.contra_account_owner).to eq("JAAPJAAP FIETS PAPIER QWDFDFGGASDFGDSFGS NV")
    end
  end

  context 'europese incasso with spaces in regex keyword' do
    before :each do
      @file_name = File.dirname(__FILE__) + '/fixtures/ing/eu_incasso_with_spaces_in_sepa.txt'
      @bank_statements = MT940Structured::Parser.parse_mt940(@file_name)["1234567"]
      @transactions = @bank_statements.flat_map(&:transactions)
      @transaction = @transactions.first
    end

    it 'has a description' do
      expect(@transaction.description).to eq('NL10XXX100020000000 01000 00000000 000000000000-AAAA12345678 Premie xxxxxxxxxxxxxxxxxxxxxxx')
    end

    it 'has a contra account' do
      expect(@transaction.contra_account).to eq("3000")
    end

    it 'has a contra account iban' do
      expect(@transaction.contra_account_iban).to eq("NL58INGB0000003000")
    end

    it 'has a contra account owner' do
      expect(@transaction.contra_account_owner).to eq("JAAPJAAP FIETS PAPIER QWDFDFGGASDFGDSFGS NV")
    end
  end

  context 'foreign transaction' do
    before :each do
      @file_name = File.dirname(__FILE__) + '/fixtures/ing/eu_incasso_foreign_transaction.txt'
      @bank_statements = MT940Structured::Parser.parse_mt940(@file_name)["1234567"]
      @transactions = @bank_statements.flat_map(&:transactions)
      @transaction = @transactions.first
    end

    it 'has a description' do
      expect(@transaction.description).to eq('GB40G01SDDCITI00000011091334 9087653421 NL0 001MKXD ADWORDS:3455667788:NL0001MKXD')
    end

    it 'has a contra account' do
      expect(@transaction.contra_account).to eq("BB123456789876567898")
    end

    it 'has a contra account iban' do
      expect(@transaction.contra_account_iban).to eq("BB123456789876567898")
    end

    it 'has a contra account owner' do
      expect(@transaction.contra_account_owner).to eq("Google Ireland Limited")
    end
  end

  describe 'new line in reference after company name' do
    before :each do
      @file_name = File.dirname(__FILE__) + '/fixtures/ing/failing.txt'
      @bank_statements = MT940Structured::Parser.parse_mt940(@file_name)["1234567"]
      @transactions = @bank_statements.flat_map(&:transactions)
      @transaction = @transactions.first
    end

    it 'has a description' do
      expect(@transaction.description).to eq('NL72 BOB998877665544 BOB213654789387485940392049 1234567898765432 Kenmerk: 3333.1111.2222.3333 Omschrijving: 987654321 01-01-2012 3 MND 9878878787 Servicecontract')
    end

    it 'has a contra account' do
      expect(@transaction.contra_account).to eq("123456789")
    end

    it 'has a contra account iban' do
      expect(@transaction.contra_account_iban).to eq("NL80RABO0123456789")
    end

    it 'has a contra account owner' do
      expect(@transaction.contra_account_owner).to eq("BOB")
    end

  end

  context 'iban mt940' do
    before :each do
      @file_name = File.dirname(__FILE__) + '/fixtures/ing/mt940_iban.txt'
      @bank_statements = MT940Structured::Parser.parse_mt940(@file_name)["12345"]
      @transactions = @bank_statements.flat_map(&:transactions)
      @transaction = @transactions.first
    end

    it 'has the correct number of transactions' do
      expect(@transactions.size).to eq(21)
    end

    it 'has a description' do
      expect(@transaction.description).to eq('22-08 -2014 Omschrijving')
    end

    it 'has a contra account' do
      expect(@transaction.contra_account).to eq("876543211")
    end

    it 'has a contra account iban' do
      expect(@transaction.contra_account_iban).to eq("NL57ABNA0876543211")
    end

    it 'has a contra account owner' do
      expect(@transaction.contra_account_owner).to eq("B Bert")
    end

    it 'has parses transaction no 19 correclty' do
      expect(@transactions[18].description).to eq("Mijn fee")
    end

    it 'has parses transaction no 9 correclty' do
      expect(@transactions[8].description).to eq("Factuurnr: 2015/123456789.00. Kijk voor meer informatie op KPN.com of Hi.nl")
      expect(@transactions[8].contra_account_iban).to eq("NL75INGB0000012345")
    end


  end

  context 'CNTP without description' do
    before :each do
      @file_name = File.dirname(__FILE__) + '/fixtures/ing/cntp_without_description.txt'
      @bank_statements = MT940Structured::Parser.parse_mt940(@file_name)["1234500"]
      @transactions = @bank_statements.flat_map(&:transactions)
      @transaction = @transactions.first
    end


    it "has the correct number of transactions" do
      expect(@transactions.size).to eq(1)
    end
  end

  context 'unscructured remi' do
    before :each do
      @file_name = File.dirname(__FILE__) + '/fixtures/ing/unstructured_remi.txt'
      @bank_statements = MT940Structured::Parser.parse_mt940(@file_name)["1234500"]
      @transactions = @bank_statements.flat_map(&:transactions)
      @transaction = @transactions.first
    end

    it "has the correct number of transactions" do
      expect(@transactions.size).to eq(2)
    end

    it 'has a contra account owner' do
      expect(@transaction.contra_account_owner).to eq("Bedrijf Die.Foobar123 AA VBBBBB NLD")
    end

    it 'has a description' do
      expect(@transaction.description).to eq("13-03-2015 09:47 TERMINALID: AA1001 PASVOLGNR: 001 TRANSACTIENR: 1234F7")
    end

  end

  context 'unscructured remi bug' do
    before :each do
      @file_name = File.dirname(__FILE__) + '/fixtures/ing/unstructured_remi_2.txt'
      @bank_statements = MT940Structured::Parser.parse_mt940(@file_name)["1231231"]
      @transactions = @bank_statements.flat_map(&:transactions)
      @transaction = @transactions.first
    end


    it "has the correct number of transactions" do
      expect(@transactions.size).to eq(1)
    end

    it 'has a description' do
      expect(@transaction.description).to eq("RC afrekening betalingsverkeer  Factuurnr. 121212 7756           Betreft rekening 33.33.333      Periode: 01-04-201 4 / 30-06-2014")
    end

  end

  context 'unscructured remi with space in keyword' do
    before :each do
      @file_name = File.dirname(__FILE__) + '/fixtures/ing/unstructured_remi_with_space_in_remi.txt'
      @bank_statements = MT940Structured::Parser.parse_mt940(@file_name)["1234567"]
      @transactions = @bank_statements.flat_map(&:transactions)
      @transaction = @transactions.first
    end

    it "has the correct number of transactions" do
      expect(@transactions.size).to eq(1)
    end

    it 'has a contra account owner' do
      expect(@transaction.contra_account_owner).to eq("B ASDGF Netherlands BV")
    end

    it 'has a description' do
      expect(@transaction.description).to eq("Factuurnummer 987654321098")
    end

  end

  context 'references' do
    before :each do
      @file_name = File.dirname(__FILE__) + '/fixtures/ing/ing_references.txt'
      @bank_statements = MT940Structured::Parser.parse_mt940(@file_name)["1212121"]
      @transactions = @bank_statements.flat_map(&:transactions)
      @transaction = @transactions.first
    end

    it 'has a customer reference' do
      expect(@transaction.customer_reference).to eq '1234123412341234'
    end

    it 'has a bank reference' do
      expect(@transaction.bank_reference).to eq '45674567456745'
    end

  end

  context 'references fix' do
    before :each do
      @file_name = File.dirname(__FILE__) + '/fixtures/ing/ing_references_fix.txt'
      @bank_statements = MT940Structured::Parser.parse_mt940(@file_name)["1212121"]
      @transactions = @bank_statements.flat_map(&:transactions)
      @transaction = @transactions.first
    end

    it 'has a bank reference' do
      expect(@transaction.bank_reference).to eq '56565656565656'
    end

  end

  context 'Remove purp from description' do
    before :each do
      @file_name = File.dirname(__FILE__) + '/fixtures/ing/ing_purp.txt'
      @bank_statements = MT940Structured::Parser.parse_mt940(@file_name)['6868686']
      @transactions = @bank_statements.flat_map(&:transactions)
      @transaction = @transactions.first
    end

    it 'has a customer reference' do
      expect(@transaction.description).to eq 'Factuurnummer 858585858585'
    end
  end

  context ':00:00' do
    before :each do
      @file_name = File.dirname(__FILE__) + '/fixtures/ing/ing_00_00.txt'
      @bank_statements = MT940Structured::Parser.parse_mt940(@file_name)['1212121']
      @transactions = @bank_statements.flat_map(&:transactions)
      @transaction = @transactions.first
    end

    it 'has a description reference' do
      expect(@transaction.description).to eq 'KASSA VERZAMELFACTUUR DINSDAG 2 ABC-654321 05/31/2017 00 :00:00'
    end
  end

  context 'dash in customer reference' do
    before :each do
      @file_name = File.dirname(__FILE__) + '/fixtures/ing/ing_dash_in_customer_reference.txt'
      @bank_statements = MT940Structured::Parser.parse_mt940(@file_name)['1212121']
      @transactions = @bank_statements.flat_map(&:transactions)
      @transaction = @transactions.first
    end

    it 'has a bank reference' do
      expect(@transaction.bank_reference).to eq '45674567456745'
    end

  end

end
