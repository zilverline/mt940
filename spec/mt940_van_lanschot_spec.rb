require_relative 'spec_helper'

describe "van Lanschot" do

  context "parse whole file" do
    let(:file_name) { File.dirname(__FILE__) + '/fixtures/van_lanschot/van_lanschot.txt' }
    let(:bank_statements) { MT940Structured::Parser.parse_mt940(file_name) }

    it "should have the correct number of bank account's" do
      expect(bank_statements.keys.size).to eq(1)
    end

    it "should have the correct number of bank statements per bank account" do
      expect(bank_statements["878787878"].size).to eq(3)
    end

    context MT940::BankStatement do
      let(:bank_statements_for_account) { bank_statements["878787878"] }

      it "should have the correct number of transactions per bank statement" do
        expect(bank_statements_for_account[0].transactions.size).to eq(1)
        expect(bank_statements_for_account[1].transactions.size).to eq(2)
        expect(bank_statements_for_account[2].transactions.size).to eq(1)
      end

      context "first bankstatement" do

        let(:bank_statement) { bank_statements_for_account[0] }

        it "has the correct previous balance" do
          balance = bank_statement.previous_balance
          expect(balance.amount).to eq(5053.33)
          expect(balance.date).to eq(Date.new(2014, 1, 3))
          expect(balance.currency).to eq("EUR")
        end

        it "has the correct next balance" do
          balance = bank_statement.new_balance
          expect(balance.amount).to eq(7770.09)
          expect(balance.date).to eq(Date.new(2014, 1, 10))
          expect(balance.currency).to eq("EUR")
        end


        context MT940::Transaction do
          let(:transaction) { bank_statement.transactions.first }

          it "should have the correct amount" do
            expect(transaction.amount).to eq(2716.76)
          end

          it "should have a description" do
            expect(transaction.description).to eq("201400-001")
          end

          it "should have an account number" do
            expect(transaction.bank_account).to eq("878787878")
          end

          it "should have a contra account number" do
            expect(transaction.contra_account).to eq("444444444")
          end

          it "should have a contra account iban number" do
            expect(transaction.contra_account_iban).to eq("NL81RABO0444444444")
          end

          it "should have a contra account owner" do
            expect(transaction.contra_account_owner).to eq("ABDFGEKSLJFN ASLDJDKE B.V")
          end

          it "should have a bank" do
            expect(transaction.bank).to eq("van Lanschot")
          end

          it "should have a currency" do
            expect(transaction.currency).to eq("EUR")
          end

          it "should have a date" do
            expect(transaction.date).to eq(Date.new(2014, 1, 10))
          end

          it "should have an eref" do
            expect(transaction.eref).to eq("333333333")
          end

        end

      end

      context "second bankstatement" do

        let(:bank_statement) { bank_statements_for_account[1] }

        it "has the correct previous balance" do
          balance = bank_statement.previous_balance
          expect(balance.amount).to eq(7770.09)
          expect(balance.date).to eq(Date.new(2014, 1, 10))
          expect(balance.currency).to eq("EUR")
        end

        it "has the correct next balance" do
          balance = bank_statement.new_balance
          expect(balance.amount).to eq(5666.09)
          expect(balance.date).to eq(Date.new(2014, 1, 13))
          expect(balance.currency).to eq("EUR")
        end

        context MT940::Transaction do
          let(:transaction) { bank_statement.transactions.first }

          it "should have a description" do
            expect(transaction.description).to eq("2222.44.111.B.02.444.0")
          end

          it "should have an account number" do
            expect(transaction.bank_account).to eq("878787878")
          end

          it "should have a contra account number" do
            expect(transaction.contra_account).to eq("2445588")
          end

          it "should have a contra account iban number" do
            expect(transaction.contra_account_iban).to eq("NL86INGB0002445588")
          end

          it "should have a contra account owner" do
            expect(transaction.contra_account_owner).to eq("belastingdienst")
          end
        end

      end

      context "third bankstatement" do

        let(:bank_statement) { bank_statements_for_account[2] }

        it "has the correct previous balance" do
          balance = bank_statement.previous_balance
          expect(balance.amount).to eq(5666.09)
          expect(balance.date).to eq(Date.new(2014, 1, 13))
          expect(balance.currency).to eq("EUR")
        end

        it "has the correct next balance" do
          balance = bank_statement.new_balance
          expect(balance.amount).to eq(4849.34)
          expect(balance.date).to eq(Date.new(2014, 1, 22))
          expect(balance.currency).to eq("EUR")
        end

        context MT940::Transaction do
          let(:transaction) { bank_statement.transactions.first }

          it "should have a description" do
            expect(transaction.description).to eq("Kenmerk: 1234.4321.0000.5555 Omschrijving: 123123444 01-01-2014  3 MND 8888888888 Servicecontract")
          end

          it "should have an account number" do
            expect(transaction.bank_account).to eq("878787878")
          end

          it "should have a contra account number" do
            expect(transaction.contra_account).to eq("676767676")
          end

          it "should have a contra account iban number" do
            expect(transaction.contra_account_iban).to eq("NL80RABO0676767676")
          end

          it "should have a contra account owner" do
            expect(transaction.contra_account_owner).to eq("BEN")
          end
        end


      end

    end

  end


  context "booking to private van lanschot account" do
    let(:file_name) { File.dirname(__FILE__) + '/fixtures/van_lanschot/to_private_account_86.txt' }
    let(:bank_statements) { MT940Structured::Parser.parse_mt940(file_name) }

    it "should have the correct number of bank account's" do
      expect(bank_statements.keys.size).to eq(1)
    end

    it "should have the correct number of bank statements per bank account" do
      expect(bank_statements["878787878"].size).to eq(1)
    end

    context MT940::BankStatement do
      let(:bank_statements_for_account) { bank_statements["878787878"] }

      it "should have the correct number of transactions per bank statement" do
        expect(bank_statements_for_account[0].transactions.size).to eq(1)
      end

      context "first bankstatement" do

        let(:bank_statement) { bank_statements_for_account[0] }

        it "has the correct previous balance" do
          balance = bank_statement.previous_balance
          expect(balance.amount).to eq(2737.51)
          expect(balance.date).to eq(Date.new(2014, 2, 24))
          expect(balance.currency).to eq("EUR")
        end

        it "has the correct next balance" do
          balance = bank_statement.new_balance
          expect(balance.amount).to eq(2584.37)
          expect(balance.date).to eq(Date.new(2014, 3, 3))
          expect(balance.currency).to eq("EUR")
        end


        context MT940::Transaction do
          let(:transaction) { bank_statement.transactions.first }

          it "should have a description" do
            expect(transaction.description).to eq("A.B.C NAME declaratie 2014")
          end

          it "should have an account number" do
            expect(transaction.bank_account).to eq("878787878")
          end

          it "should have a contra account number" do
            expect(transaction.contra_account).to eq("111111110")
          end


        end

      end

    end

  end

  context "unspecified contra account" do
    let(:file_name) { File.dirname(__FILE__) + '/fixtures/van_lanschot/unspecified_contra_account.txt' }
    let(:bank_statements) { MT940Structured::Parser.parse_mt940(file_name) }

    it "should have the correct number of bank account's" do
      expect(bank_statements.keys.size).to eq(1)
    end

    it "should have the correct number of bank statements per bank account" do
      expect(bank_statements["878787878"].size).to eq(1)
    end

    context MT940::BankStatement do
      let(:bank_statements_for_account) { bank_statements["878787878"] }

      it "should have the correct number of transactions per bank statement" do
        expect(bank_statements_for_account[0].transactions.size).to eq(1)
      end

      context "first bankstatement" do

        let(:bank_statement) { bank_statements_for_account[0] }

        it "has the correct previous balance" do
          balance = bank_statement.previous_balance
          expect(balance.amount).to eq(3592.00)
          expect(balance.date).to eq(Date.new(2014, 4, 1))
          expect(balance.currency).to eq("EUR")
        end

        it "has the correct next balance" do
          balance = bank_statement.new_balance
          expect(balance.amount).to eq(3571.08)
          expect(balance.date).to eq(Date.new(2014, 4, 3))
          expect(balance.currency).to eq("EUR")
        end


        context MT940::Transaction do
          let(:transaction) { bank_statement.transactions.first }

          it "should have a description" do
            expect(transaction.description).to eq("AAAAAAAAA SFDADSFG         asdfASDFASDF     ASDFASFASERIODE: 01-01-2014 / 31-03-2014")
          end

          it "should have an account number" do
            expect(transaction.bank_account).to eq("878787878")
          end

          it "should have a contra account number" do
            expect(transaction.contra_account).to be_nil
          end


        end

      end

    end

  end
end
