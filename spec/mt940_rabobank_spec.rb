require_relative 'spec_helper'

describe "Rabobank" do

  context "parse whole file" do
    let(:file_name) { File.dirname(__FILE__) + '/fixtures/rabobank.txt' }
    let(:bank_statements) { MT940Structured::Parser.parse_mt940(file_name) }

    it "should have the correct number of bank account's" do
      expect(bank_statements.keys.size).to eq(1)
    end

    it "should have the correct number of bank statements per bank account" do
      expect(bank_statements["212121211"].size).to eq(23)
    end

    context MT940::BankStatement do
      let(:bank_statements_for_account) { bank_statements["212121211"] }

      it "should have the correct number of transactions per bank statement" do
        expect(bank_statements_for_account[0].transactions.size).to eq(1)
        expect(bank_statements_for_account[1].transactions.size).to eq(0)
        expect(bank_statements_for_account[10].transactions.size).to eq(2)
      end

      context "single bank statement" do
        let(:bank_statement) { bank_statements_for_account[0] }

        it "should have a correct previous balance per statement" do
          balance = bank_statement.previous_balance
          expect(balance.amount).to eq(17431.67)
          expect(balance.date).to eq(Date.new(2012, 9, 28))
          expect(balance.currency).to eq("EUR")
        end

        it "should have a correct next balance per statement" do
          balance = bank_statement.new_balance
          expect(balance.amount).to eq(17381.67)
          expect(balance.date).to eq(Date.new(2012, 10, 1))
          expect(balance.currency).to eq("EUR")
        end

        it "should have an iban" do
          expect(bank_statement.bank_account_iban).to be_nil
        end


        context "debit transaction" do

          let(:transaction) { bank_statement.transactions.first }

          it "should have the correct amount" do
            expect(transaction.amount).to eq(-50)
          end

          it "should have a description" do
            expect(transaction.description).to eq("Incasso deposit Savings Account")
          end

          it "should have an account number" do
            expect(transaction.bank_account).to eq("212121211")
          end

          it "should have a contra account number" do
            expect(transaction.contra_account).to eq("1313131319")
          end

          it "should have a contra account owner" do
            expect(transaction.contra_account_owner).to eq("J. DOE")
          end

          it "should have a bank" do
            expect(transaction.bank).to eq("Rabobank")
          end

          it "should have a currency" do
            expect(transaction.currency).to eq("EUR")
          end

          it "should have a date" do
            expect(transaction.date).to eq(Date.new(2012, 10, 1))
          end

          it "should have a type" do
            expect(transaction.type).to eq("Machtiging Rabobank")
          end

        end

      end

      context "credit transaction" do
        let(:transaction) { bank_statements_for_account[12].transactions[1] }

        it "should have the correct amount" do
          expect(transaction.amount).to eq(12100.00)
        end

        it "should have the correct type" do
          expect(transaction.type).to eq("Bijschrijving betaalopdracht")
        end

        it "should have the correct contra account" do
          expect(transaction.contra_account).to eq("987654321")
        end

        it "should have the correct contra account owner" do
          expect(transaction.contra_account_owner).to eq("COMPANY B.V.")
        end

      end

      context "transaction with a GIRO number" do
        let(:transaction) { bank_statements_for_account[18].transactions.first }

        it "should have the correct contra account" do
          expect(transaction.contra_account).to eq("2445588")
        end

        it "should have the correct contra account owner" do
          expect(transaction.contra_account_owner).to eq("Belastingdienst")
        end
      end

      context "with a unknown contra account" do
        let(:transaction) { bank_statements_for_account[3].transactions.first }

        it "should have a NONREF as contra account" do
          expect(transaction.contra_account).to eq("NONREF")
        end

        it "should have a contra account owner" do
          expect(transaction.contra_account_owner).to eq("Kosten")
        end

        it "should have a type" do
          expect(transaction.type).to eq("Afschrijving rente provisie kosten")
        end
      end

      context "multi line description" do
        let(:transaction) { bank_statements_for_account[5].transactions.first }

        it "should have the correct description" do
          expect(transaction.description).to eq("BETALINGSKENM.  490022201282 ARBEIDS ONG. VERZ. 00333333333 PERIODE 06.10.2012 - 06.11.2012")
        end

        it "should have a type" do
          expect(transaction.type).to eq("Doorlopende machtiging algemeen")
        end
      end
    end

  end

  context "deposit from savings account" do
    let(:file_name) { File.dirname(__FILE__) + '/fixtures/rabobank_mt940_structured_to_savings_account.txt' }
    let(:bank_statements) { MT940Structured::Parser.parse_mt940(file_name) }

    it "should have the correct contra account number" do
      bank_statement = bank_statements["123456789"][0]
      transaction = bank_statement.transactions.first
      expect(transaction.contra_account).to eq("1098765432")
      expect(transaction.contra_account_iban).to eq("NL03RABO1098765432")
    end

  end

  context "savings account" do
    let(:file_name) { File.dirname(__FILE__) + '/fixtures/rabobank_mt940_structured_savings_account.txt' }
    let(:bank_statements) { MT940Structured::Parser.parse_mt940(file_name) }

    it "should have the correct accountnumber" do
      expect(bank_statements["9123456789"].size).to eq(1)
    end

  end

  context "structured betalingskenmerk" do
    let(:file_name) { File.dirname(__FILE__) + '/fixtures/rabobank_mt940_structured_dutch_tax.txt' }
    let(:bank_statements) { MT940Structured::Parser.parse_mt940(file_name) }

    it "should put a structuted betalingskenmerk in the description" do
      bank_statement = bank_statements["123456789"][0]
      transaction = bank_statement.transactions.first
      expect(transaction.description).to eq("BETALINGSKENMERK 1234567899874563")
    end
  end

  context "structured multiline description" do
    let(:file_name) { File.dirname(__FILE__) + '/fixtures/rabobank_mt940_structured_multi_line.txt' }
    let(:bank_statements) { MT940Structured::Parser.parse_mt940(file_name) }

    it "handles multiline in the description" do
      bank_statement = bank_statements["123456789"][0]
      transaction = bank_statement.transactions.first
      expect(transaction.description).to eq("Factuur 20 14-002")
    end

  end

  context "mt 940 structured" do
    let(:file_name) { File.dirname(__FILE__) + '/fixtures/rabobank_mt940_structured.txt' }
    let(:bank_statements) { MT940Structured::Parser.parse_mt940(file_name) }

    it "should have the correct number of bank account's" do
      expect(bank_statements.keys.size).to eq(1)
    end

    it "should have the correct number of bank statements per bank account" do
      expect(bank_statements["123456789"].size).to eq(2)
    end

    context MT940::BankStatement do
      let(:bank_statements_for_account) { bank_statements["123456789"] }

      it "should have the correct number of transactions per bank statement" do
        expect(bank_statements_for_account[0].transactions.size).to eq(2)
        expect(bank_statements_for_account[1].transactions.size).to eq(7)
      end

      context "single bank statement" do
        let(:bank_statement) { bank_statements_for_account[0] }

        it "should have a correct previous balance per statement" do
          balance = bank_statement.previous_balance
          expect(balance.amount).to eq(1147.95)
          expect(balance.date).to eq(Date.new(2013, 4, 2))
          expect(balance.currency).to eq("EUR")
        end

        it "should have a correct next balance per statement" do
          balance = bank_statement.new_balance
          expect(balance.amount).to eq(1190.35)
          expect(balance.date).to eq(Date.new(2013, 4, 3))
          expect(balance.currency).to eq("EUR")
        end

        it "should have an iban" do
          expect(bank_statement.bank_account_iban).to eq("NL50RABO0123456789")
        end

        context "debit transaction" do

          let(:transaction) { bank_statement.transactions.first }

          it "should have the correct amount" do
            expect(transaction.amount).to eq(-127.5)
          end

          it "should have a description" do
            expect(transaction.description).to eq("674725433 1120000153447185 14144467636004962")
          end

          it "should have an account number" do
            expect(transaction.bank_account).to eq("123456789")
          end

          it "should have an iban number" do
            expect(transaction.bank_account_iban).to eq("NL50RABO0123456789")
          end

          it "should have a contra account number" do
            expect(transaction.contra_account).to eq("523149468")
          end

          it "should have a contra account iban" do
            expect(transaction.contra_account_iban).to eq("NL96RBOS0523149468")
          end

          it "should have a contra account owner" do
            expect(transaction.contra_account_owner).to eq("Nespresso Nede rland B.V.")
          end

          it "should have a bank" do
            expect(transaction.bank).to eq("Rabobank")
          end

          it "should have a currency" do
            expect(transaction.currency).to eq("EUR")
          end

          it "should have a date" do
            expect(transaction.date).to eq(Date.new(2013, 4, 3))
          end

          it "should have a type" do
            expect(transaction.type).to eq("Betaalopdracht iDEAL")
          end

        end

      end

      context "credit transaction" do
        let(:transaction) { bank_statements_for_account[0].transactions[1] }

        it "should have the correct amount" do
          expect(transaction.amount).to eq(169.90)
        end

        it "should have the correct type" do
          expect(transaction.type).to eq("Bijschrijving crediteurenbetaling")
        end

        it "should have the correct contra account" do
          expect(transaction.contra_account).to eq("663616476")
        end

        it "should have the correct contra account iban" do
          expect(transaction.contra_account_iban).to be_nil
        end

        it "should have the correct contra account owner" do
          expect(transaction.contra_account_owner).to eq("Bedrijf B.V.")
        end

      end

      context "transaction with a GIRO number" do
        let(:transaction) { bank_statements_for_account[1].transactions.first }

        it "should have the correct contra account" do
          expect(transaction.contra_account).to eq("4500018")
        end

        it "should have the correct contra account iban" do
          expect(transaction.contra_account_iban).to eq(nil)
        end

        it "should have the correct contra account owner" do
          expect(transaction.contra_account_owner).to eq("DIVV afd parkeergebouwewn")
        end
      end

      context "with a unknown contra account" do
        let(:transaction) { bank_statements_for_account[1].transactions[3] }

        it "should have a NONREF as contra account" do
          expect(transaction.contra_account).to eq("NONREF")
        end

        it "should have a nil as contra account iban" do
          expect(transaction.contra_account_iban).to be_nil
        end

        it "should have a type" do
          expect(transaction.type).to eq("Afschrijving rente provisie kosten")
        end
      end

      context 'without a proper description' do
        let(:transaction) { bank_statements_for_account[1].transactions[4] }

        it 'should have an empty description' do
          expect(transaction.description).to eq('')
        end
      end

    end
  end

  it "should be able to handle a debet current balance" do
    debet_file_name = File.dirname(__FILE__) + '/fixtures/rabobank_with_debet_previous_balance.txt'
    bank_statement = MT940Structured::Parser.parse_mt940(debet_file_name)["129199348"].first

    expect(bank_statement.previous_balance.amount).to eq(-12)
    expect(bank_statement.previous_balance.currency).to eq("EUR")
    expect(bank_statement.previous_balance.date).to eq(Date.new(2012, 10, 4))

    expect(bank_statement.new_balance.amount).to eq(-12)
    expect(bank_statement.new_balance.currency).to eq("EUR")
    expect(bank_statement.new_balance.date).to eq(Date.new(2012, 10, 5))
  end

  context "handle EREF" do
    let(:file_name) { File.dirname(__FILE__) + '/fixtures/import-16-06-2014.txt' }
    let(:bank_statements) { MT940Structured::Parser.parse_mt940(file_name) }

    it "should have the correct number of bank accounts" do
      expect(bank_statements.keys.size).to eq(1)
    end

    it "should have the correct number of bank statements per bank account" do
      expect(bank_statements["156750961"].size).to eq(1)
    end

    it "should parse EREF banktransaction" do
      expect(bank_statements["156750961"][0].transactions[0].contra_account_owner).to eq("ECOMMERCE INDUSTRIES INC EUROPE B.V")
      expect(bank_statements["156750961"][0].transactions[0].eref).to eq("201405-258")
    end
  end

  context "handle duplicate occurrence of REMI" do
    let(:file_name) { File.dirname(__FILE__) + '/fixtures/rabobank/fix_rabo_twice_remi.txt' }
    let(:bank_statements) { MT940Structured::Parser.parse_mt940(file_name) }
    let(:transaction) { bank_statements['1212121212'][0].transactions[0] }

    it "should have the correct number of bank accounts" do
      expect(bank_statements.keys.size).to eq(1)
    end

    it "should have the correct amount" do
      expect(transaction.amount).to eq(1000.0)
    end

    it "should have the correct type" do
      expect(transaction.type).to eq("541")
    end

    it "should have the correct contra account" do
      expect(transaction.contra_account).to eq("O044444444")
    end

    it "should have the correct contra account iban" do
      expect(transaction.contra_account_iban).to eq "NL55RABO044444444"
    end

    it "should have the correct contra account owner" do
      expect(transaction.contra_account_owner).to eq("STG. KLANTGELDEN SEPAY")
    end

    it "should have the correct description" do
      expect(transaction.description).to eq("AFR EK. BETAALAUTOMAAT MaestroREFNR. H6MJV5DAT. 20170601 AANT. 11")
    end
  end

  context "handle linebreack in keyword REMI" do
    let(:file_name) { File.dirname(__FILE__) + '/fixtures/rabobank/line_break_in_remi.txt' }
    let(:bank_statements) { MT940Structured::Parser.parse_mt940(file_name) }
    let(:transaction) { bank_statements['1212121212'][0].transactions[0] }

    it "should have the correct number of bank accounts" do
      expect(bank_statements.keys.size).to eq(1)
    end

    it "should have the correct amount" do
      expect(transaction.amount).to eq(1000.0)
    end

    it "should have the correct type" do
      expect(transaction.type).to eq("541")
    end

    it "should have the correct contra account" do
      expect(transaction.contra_account).to eq("O044444444")
    end

    it "should have the correct contra account iban" do
      expect(transaction.contra_account_iban).to eq "NL55RABO044444444"
    end

    it "should have the correct contra account owner" do
      expect(transaction.contra_account_owner).to eq("AAAAAA RRRRRRRRRRR BBBBB DFDFDFDFDFDFDF CCC")
    end

    it "should have the correct description" do
      expect(transaction.description).to eq("BETALINGSKENM.: 342157/DEC- 16, ONZE REF.: 12345678, TOELICHTIN B: Gruitjes")
    end
  end

  context 'handles end of file sign as first char of line' do
    let(:file_name) { File.dirname(__FILE__) + '/fixtures/rabobank/dash_as_start_of_line.txt' }
    let(:bank_statements) { MT940Structured::Parser.parse_mt940(file_name) }
    let(:transaction) { bank_statements['1212121212'][0].transactions[0] }

    it 'parses' do
      expect(bank_statements.keys.size).to eq(1)
    end

    it "should have the correct amount" do
      expect(transaction.amount).to eq(1000.0)
    end
  end

end
