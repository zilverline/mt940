require_relative 'spec_helper'

describe MT940Structured::Parser do

  before :each do
    @file_name = File.dirname(__FILE__) + "/fixtures/abn/#{file_name}"
    @bank_statements = MT940Structured::Parser.parse_mt940(@file_name)[bank_account_number]
    @transactions = @bank_statements.flat_map(&:transactions)
    @transaction = @transactions.first
  end
  context 'classic mt940' do
    let(:file_name) { 'abnamro.txt' }
    let(:bank_account_number) { '517852257' }

    it 'have the correct number of transactions' do
      expect(@transactions.size).to eq(10)
    end

    it 'get the opening balance and date' do
      expect(@bank_statements.first.previous_balance.amount).to eq(3236.28)
      expect(@bank_statements.first.previous_balance.date).to eq(Date.new(2011, 5, 22))
    end

    it 'get the closing balance and date' do
      expect(@bank_statements.last.new_balance.amount).to eq(1849.75)
      expect(@bank_statements.last.new_balance.date).to eq(Date.new(2011, 5, 24))
    end

    context 'Transaction' do

      it 'have a bank_account' do
        expect(@transaction.bank_account).to eq('517852257')
      end

      it 'have an amount' do
        expect(@transaction.amount).to eq(-9.00)
      end

      context 'Description' do
        it 'have the correct description in case of a GIRO account' do
          expect(@transaction.description).to eq('KPN - DIGITENNE    BETALINGSKENM.  0000000421886595314606715                       BETREFT FACTUUR D.D. 20-05-2011INCL. 1,44 BTW')
        end

        it 'have the correct description in case of a regular bank' do
          expect(@transactions.last.description).to eq('MYCOM DEN HAAG  S-GRAVEN,PAS999')
        end
      end

      it 'have a date' do
        expect(@transaction.date).to eq(Date.new(2011, 5, 24))
      end

      it 'return its bank' do
        expect(@transaction.bank).to eq('Abnamro')
      end

      it 'have a currency' do
        expect(@transaction.currency).to eq('EUR')
      end

      context 'Contra account' do
        it 'be determined in case of a GIRO account' do
          expect(@transaction.contra_account).to eq('000428428')
        end

        it 'be determined in case of a regular bank' do
          expect(@transactions.last.contra_account).to eq('528939882')
        end
      end
    end
  end

  context 'sepa mt940' do
    let(:file_name) { 'abnamro_structured.txt' }
    let(:bank_account_number) { '123212321' }

    it 'have the correct number of transactions' do
      expect(@transactions.size).to eq(10)
    end

    it 'get the opening balance and date' do
      expect(@bank_statements.first.previous_balance.amount).to eq(10000.9)
      expect(@bank_statements.first.previous_balance.date).to eq(Date.new(2014, 1, 12))
    end

    it 'get the closing balance and date' do
      expect(@bank_statements.last.new_balance.amount).to eq(3976.9)
      expect(@bank_statements.last.new_balance.date).to eq(Date.new(2014, 1, 27))
    end

    context 'nonref' do
      let(:transaction) { @transactions.first }

      it 'has a NONREF when contraaccount is unknown' do
        expect(transaction.contra_account).to eq('NONREF')
      end

    end

    context 'Transaction' do

      let(:transaction) { @transactions[1] }

      it 'have a bank_account' do
        expect(transaction.bank_account).to eq('123212321')
      end

      it 'have an amount' do
        expect(transaction.amount).to eq(-10)
      end

      it 'have the correct description in case of a regular bank' do
        expect(transaction.description).to eq('BEA   NR:NND130   13.01.14/11.00 XXXXX 99 XXXXXX BV AMSTE,PAS123')
      end

      it 'have a date' do
        expect(transaction.date).to eq(Date.new(2014, 1, 13))
      end

      it 'return its bank' do
        expect(transaction.bank).to eq('Abnamro')
      end

      it 'have a currency' do
        expect(transaction.currency).to eq('EUR')
      end

    end

    context 'sepa overboeking' do

      let(:transaction) { @transactions[2] }

      it 'have a bank_account' do
        expect(transaction.bank_account).to eq('123212321')
      end

      it 'have an amount' do
        expect(transaction.amount).to eq(-10)
      end

      it 'have the correct description in case of a regular bank' do
        expect(transaction.description).to eq("SAVINGS")
      end

      it 'have a date' do
        expect(transaction.date).to eq(Date.new(2014, 1, 13))
      end

      it 'return its bank' do
        expect(transaction.bank).to eq('Abnamro')
      end

      it 'have a currency' do
        expect(transaction.currency).to eq('EUR')
      end

      it 'has a contra account' do
        expect(transaction.contra_account).to eq('987654321')
      end

      it 'has a contra account iban' do
        expect(transaction.contra_account_iban).to eq('NL25ABNA0987654321')
      end

      it 'has a contra account owner' do
        expect(transaction.contra_account_owner).to eq('FOOBAR')
      end
    end

    context 'sepa ideal' do
      let(:transaction) { @transactions[3] }

      it 'have a bank_account' do
        expect(transaction.bank_account).to eq('123212321')
      end

      it 'have an amount' do
        expect(transaction.amount).to eq(4)
      end

      it 'have the correct description in case of a regular bank' do
        expect(transaction.description).to eq(%Q{4851430136 0030000 735822580 NS E-TICKET(S)KENMERK: 26-01-2014 18:14 003000 0735822580})
      end

      it 'have a date' do
        expect(transaction.date).to eq(Date.new(2014, 1, 26))
      end

      it 'return its bank' do
        expect(transaction.bank).to eq('Abnamro')
      end

      it 'have a currency' do
        expect(transaction.currency).to eq('EUR')
      end

      it 'has a contra account' do
        expect(transaction.contra_account).to eq('888888888')
      end

      it 'has a contra account iban' do
        expect(transaction.contra_account_iban).to eq('NL70ABNA0888888888')
      end

      it 'has a contra account owner' do
        expect(transaction.contra_account_owner).to eq('NS GROEP INZAKE NSR IDEA')
      end

    end

    context 'SEPA ACCEPTGIROBETALING' do
      let(:transaction) { @transactions[5] }

      it 'have a bank_account' do
        expect(transaction.bank_account).to eq('123212321')
      end

      it 'have an amount' do
        expect(transaction.amount).to eq(-1000)
      end

      it 'have the correct description in case of a regular bank' do
        expect(transaction.description).to eq(%Q{BETALINGSKENM.: 1234567890098876 ID DEBITEUR: 777777777})
      end

      it 'have a date' do
        expect(transaction.date).to eq(Date.new(2014, 1, 26))
      end

      it 'return its bank' do
        expect(transaction.bank).to eq('Abnamro')
      end

      it 'have a currency' do
        expect(transaction.currency).to eq('EUR')
      end

      it 'has a contra account' do
        expect(transaction.contra_account).to eq('2445588')
      end

      it 'has a contra account iban' do
        expect(transaction.contra_account_iban).to eq('NL86INGB0002445588')
      end

      it 'has a contra account owner' do
        expect(transaction.contra_account_owner).to eq('BELASTINGDIENST')
      end

    end

  end

  context 'sepa overboeking belastingdienst' do
    let(:file_name) { 'anb_sepa_overboeking_belastingdienst.txt' }
    let(:bank_account_number) { '123456789' }
    let(:transaction) { @transactions[1] }

    it 'have a bank_account' do
      expect(transaction.bank_account).to eq('123456789')
    end

    it 'have an amount' do
      expect(transaction.amount).to eq(-500)
    end

    it 'have the correct description in case of a regular bank' do
      expect(transaction.description).to eq("BETALINGSKENM.: 1234123412345678")
    end

    it 'have a date' do
      expect(transaction.date).to eq(Date.new(2020, 5, 4))
    end

    it 'return its bank' do
      expect(transaction.bank).to eq('Abnamro')
    end

    it 'have a currency' do
      expect(transaction.currency).to eq('EUR')
    end

    it 'has a contra account' do
      expect(transaction.contra_account).to eq('2445588')
    end

    it 'has a contra account iban' do
      expect(transaction.contra_account_iban).to eq('NL86INGB0002445588')
    end

    it 'has a contra account owner' do
      expect(transaction.contra_account_owner).to eq('BELASTINGDIENST APELDOORN')
    end

  end

  context 'sepa overboeking style 2' do
    let(:file_name) { 'abn_sepa_overboeking.txt' }
    let(:bank_account_number) { '555555555' }

    it 'has a contra account iban' do
      expect(@transaction.contra_account_iban).to eq 'NL56CHAS0101010101'
    end

    it 'has a contra account' do
      expect(@transaction.contra_account).to eq '101010101'
    end

    it 'has a contra account owner' do
      expect(@transaction.contra_account_owner).to eq 'AA GHGHGH NETHERLANDS B.V.'
    end

    it 'has a description' do
      expect(@transaction.description).to eq '1412DEC 2015 CONSU LTINGKENMERK: 7541410'
    end
  end

  context 'SEPA INCASSO ALGEMEEN DOORLOPEND' do
    let(:file_name) { 'abn_sepa_incasso_doorlopend.txt' }
    let(:bank_account_number) { '555555555' }

    it 'has a contra account iban' do
      expect(@transaction.contra_account_iban).to eq 'NL83RABO0353535355'
    end

    it 'has a contra account' do
      expect(@transaction.contra_account).to eq '353535355'
    end

    it 'has a contra account owner' do
      expect(@transaction.contra_account_owner).to eq 'BHBBAAA B.V.'
    end

    it 'has a description' do
      expect(@transaction.description).to eq 'MAANDTERMIJN JANUA RI'
    end

  end

  context 'SEPA PERIODIEKE OVERB' do
    let(:file_name) { 'abn_sepa_periodieke_overboeking.txt' }
    let(:bank_account_number) { '555555555' }

    it 'has a contra account iban' do
      expect(@transaction.contra_account_iban).to eq 'NL52ABNA0777777777'
    end

    it 'has a contra account' do
      expect(@transaction.contra_account).to eq '777777777'
    end

    it 'has a contra account owner' do
      expect(@transaction.contra_account_owner).to eq 'B C DE MAN'
    end

    it 'has a description' do
      expect(@transaction.description).to eq 'SALARIS G.G. DE MAN'
    end

  end

  context 'structured mt940' do
    let(:bank_account_number) { '555555555' }

    context 'sepa overboeking' do
      let(:file_name) { 'abn_structured_sepa_overboeking.txt' }

      it 'has a contra account iban' do
        expect(@transaction.contra_account_iban).to eq 'NL57INGB0001212121'
      end

      it 'has a contra account' do
        expect(@transaction.contra_account).to eq '1212121'
      end

      it 'has a contra account owner' do
        expect(@transaction.contra_account_owner).to eq 'CAFE MON AMI'
      end

      it 'has a description' do
        expect(@transaction.description).to eq '897789005'
      end

      it 'has a eref' do
        expect(@transaction.eref).to eq 'NOTPROVIDED'
      end
    end

    context 'sepa ideal' do
      let(:file_name) { 'abn_structured_sepa_ideal.txt' }

      it 'has a contra account iban' do
        expect(@transaction.contra_account_iban).to eq 'NL30ABNA0122365478'
      end

      it 'has a contra account' do
        expect(@transaction.contra_account).to eq '122365478'
      end

      it 'has a contra account owner' do
        expect(@transaction.contra_account_owner).to eq 'ABC POPPIEKLAMNAET'
      end

      it 'has a description' do
        expect(@transaction.description).to eq 'K00023345Mq235234 0045623157461347 FACTUUR 10530 000848KLAOCFTUIOMFND'
      end

      it 'has a eref' do
        expect(@transaction.eref).to eq '11-09-2015 12:00 0045623157461347'
      end
    end

    context 'sepa acceptgiro' do
      let(:file_name) { 'abn_structured_sepa_acceptgiro.txt' }

      it 'has a contra account iban' do
        expect(@transaction.contra_account_iban).to eq 'NL86INGB0002445588'
      end

      it 'has a contra account' do
        expect(@transaction.contra_account).to eq '2445588'
      end

      it 'has a contra account owner' do
        expect(@transaction.contra_account_owner).to eq 'BELASTINGDIENST'
      end

      it 'has a description' do
        expect(@transaction.description).to eq 'ISSUER: CUR                  REF: 4420043232693268'
      end

      it 'has a eref' do
        expect(@transaction.eref).to eq 'NOTPROVIDED'
      end
    end

  end
end
