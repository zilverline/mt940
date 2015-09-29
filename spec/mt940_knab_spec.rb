require_relative 'spec_helper'

describe "Knab" do

  context "parse whole file" do
    let(:file_name) { File.dirname(__FILE__) + '/fixtures/knab/knab.txt' }
    let(:bank_statements) { MT940Structured::Parser.parse_mt940(file_name) }

    it "should have the correct number of bank account's" do
      expect(bank_statements.keys.size).to eq(1)
    end

    it "should have the correct number of bank statements per bank account" do
      expect(bank_statements["123456789"].size).to eq(1)
    end

    context MT940::BankStatement do
      let(:bank_statements_for_account) { bank_statements["123456789"] }

      it "should have the correct number of transactions per bank statement" do
        expect(bank_statements_for_account[0].transactions.size).to eq(2)
      end

      it "should have a correct previous balance per statement" do
        balance = bank_statements_for_account[0].previous_balance
        expect(balance.amount).to eq(0.0)
        expect(balance.date).to eq(Date.new(2014, 10, 24))
        expect(balance.currency).to eq("EUR")
      end

      it "should have a correct next balance per statement" do
        balance = bank_statements_for_account[0].new_balance
        expect(balance.amount).to eq(1010.0)
        expect(balance.date).to eq(Date.new(2014, 10, 27))
        expect(balance.currency).to eq("EUR")
      end

      context MT940::Transaction do
        let(:transaction) { bank_statements["123456789"].first.transactions.first }

        it "should have the correct amount" do
          expect(transaction.amount).to eq(1000)
        end

        it "should have a description" do
          expect(transaction.description).to eq("REK: NL26ABNA0999999999/NAAM: BEDRIJF VOF")
        end

        it "should have an account number" do
          expect(transaction.bank_account).to eq("123456789")
        end

        it "should have a contra account number" do
          expect(transaction.contra_account).to eq("999999999")
        end

        it "should have a contra account iban number" do
          expect(transaction.contra_account_iban).to eq("NL26ABNA0999999999")
        end

        it "should have a contra account owner" do
          expect(transaction.contra_account_owner).to eq("BEDRIJF VOF")
        end

        it "should have a bank" do
          expect(transaction.bank).to eq("Knab")
        end

        it "should have a currency" do
          expect(transaction.currency).to eq("EUR")
        end

        it "should have a date" do
          expect(transaction.date).to eq(Date.new(2014, 10, 24))
        end

      end

    end

  end

  context "parse a file with multiple blocks in it" do
    let(:file_name) { File.dirname(__FILE__) + '/fixtures/knab/knab_two_blocks.txt' }
    let(:bank_statements) { MT940Structured::Parser.parse_mt940(file_name) }

    it "should have the correct number of bank account's" do
      expect(bank_statements.keys.size).to eq(1)
    end

    it "should have the correct number of bank statements per bank account" do
      expect(bank_statements["222222222"].size).to eq(2)
    end

    context MT940::BankStatement do
      let(:bank_statements_for_account) { bank_statements["222222222"] }

      it "should have the correct number of transactions per bank statement" do
        expect(bank_statements_for_account[0].transactions.size).to eq(1)
        expect(bank_statements_for_account[1].transactions.size).to eq(2)
      end

      context "first statement" do

        let(:bank_statement) { bank_statements_for_account[0] }

        it "has the correct previous balance" do
          balance = bank_statement.previous_balance
          expect(balance.amount).to eq(0.0)
          expect(balance.date).to eq(Date.new(2014, 10, 22))
          expect(balance.currency).to eq("EUR")
        end

        it "has the correct next balance" do
          balance = bank_statements_for_account[0].new_balance
          expect(balance.amount).to eq(50.0)
          expect(balance.date).to eq(Date.new(2014, 10, 23))
          expect(balance.currency).to eq("EUR")
        end
        context MT940::Transaction do
          let(:transaction) { bank_statement.transactions.first }

          it "should have the correct amount" do
            expect(transaction.amount).to eq(50)
          end

          it "should have a description" do
            expect(transaction.description).to eq("AAAAA BDBDNDKDKASDF, BETALINGSKENMERK: 00111111111, REFERENTI BC0101111111, 22-10-2014 15:01 REK: 90000014/NAAM: KNAB")
          end

          it "should have an account number" do
            expect(transaction.bank_account).to eq("222222222")
          end

          it "should have a contra account number" do
            expect(transaction.contra_account).to eq("90000014")
          end

          it "should have a contra account iban number" do
            expect(transaction.contra_account_iban).to be_nil
          end

          it "should have a contra account owner" do
            expect(transaction.contra_account_owner).to eq("KNAB")
          end

          it "should have a bank" do
            expect(transaction.bank).to eq("Knab")
          end

          it "should have a currency" do
            expect(transaction.currency).to eq("EUR")
          end

          it "should have a date" do
            expect(transaction.date).to eq(Date.new(2014, 10, 22))
          end

        end

      end

      context "second statement" do

        let(:bank_statement) { bank_statements_for_account[1] }

        it "has the correct previous balance" do
          balance = bank_statement.previous_balance
          expect(balance.amount).to eq(50.0)
          expect(balance.date).to eq(Date.new(2014, 10, 24))
          expect(balance.currency).to eq("EUR")
        end

        it "has the correct next balance" do
          balance = bank_statement.new_balance
          expect(balance.amount).to eq(1060.0)
          expect(balance.date).to eq(Date.new(2014, 10, 27))
          expect(balance.currency).to eq("EUR")
        end
      end

    end

  end

  context "invalid file" do
    let(:file_name) { File.dirname(__FILE__) + '/fixtures/knab/knab_invalid.txt' }

    it 'fails fast' do
      expect { MT940Structured::Parser.parse_mt940(file_name) }.to raise_exception(MT940Structured::InvalidFileContentError)
    end

  end
end
