require_relative 'spec_helper'

describe "Knab" do

  context "parse whole file" do
    let(:file_name) { File.dirname(__FILE__) + '/fixtures/van_lanschot/van_lanschot.txt' }
    let(:bank_statements) { MT940Structured::Parser.parse_mt940(file_name) }

    it "should have the correct number of bank account's" do
      bank_statements.keys.size.should == 1
    end

    it "should have the correct number of bank statements per bank account" do
      bank_statements["878787878"].size.should == 3
    end

    context MT940::BankStatement do
      let(:bank_statements_for_account) { bank_statements["878787878"] }

      it "should have the correct number of transactions per bank statement" do
        bank_statements_for_account[0].transactions.size.should == 1
        bank_statements_for_account[1].transactions.size.should == 2
        bank_statements_for_account[2].transactions.size.should == 1
      end

      context "first bankstatement" do

        let(:bank_statement) { bank_statements_for_account[0] }

        it "has the correct previous balance" do
          balance = bank_statement.previous_balance
          balance.amount.should == 5053.33
          balance.date.should == Date.new(2014, 1, 3)
          balance.currency.should == "EUR"
        end

        it "has the correct next balance" do
          balance = bank_statement.new_balance
          balance.amount.should == 7770.09
          balance.date.should == Date.new(2014, 1, 10)
          balance.currency.should == "EUR"
        end


        context MT940::Transaction do
          let(:transaction) { bank_statement.transactions.first }

          it "should have the correct amount" do
            transaction.amount.should == 2716.76
          end

          it "should have a description" do
            transaction.description.should == "201400-001"
          end

          it "should have an account number" do
            transaction.bank_account.should == "878787878"
          end

          it "should have a contra account number" do
            transaction.contra_account.should == "444444444"
          end

          it "should have a contra account iban number" do
            transaction.contra_account_iban.should == "NL81RABO0444444444"
          end

          it "should have a contra account owner" do
            transaction.contra_account_owner.should == "ABDFGEKSLJFN ASLDJDKE B.V"
          end

          it "should have a bank" do
            transaction.bank.should == "van Lanschot"
          end

          it "should have a currency" do
            transaction.currency.should == "EUR"
          end

          it "should have a date" do
            transaction.date.should == Date.new(2014, 1, 10)
          end

          it "should have an eref" do
            transaction.eref.should == "333333333"
          end

        end

      end

      context "second bankstatement" do

        let(:bank_statement) { bank_statements_for_account[1] }

        it "has the correct previous balance" do
          balance = bank_statement.previous_balance
          balance.amount.should == 7770.09
          balance.date.should == Date.new(2014, 1, 10)
          balance.currency.should == "EUR"
        end

        it "has the correct next balance" do
          balance = bank_statement.new_balance
          balance.amount.should == 5666.09
          balance.date.should == Date.new(2014, 1, 13)
          balance.currency.should == "EUR"
        end

        context MT940::Transaction do
          let(:transaction) { bank_statement.transactions.first }

          it "should have a description" do
            transaction.description.should == "2222.44.111.B.02.444.0"
          end

          it "should have an account number" do
            transaction.bank_account.should == "878787878"
          end

          it "should have a contra account number" do
            transaction.contra_account.should == "2445588"
          end

          it "should have a contra account iban number" do
            transaction.contra_account_iban.should == "NL86INGB0002445588"
          end

          it "should have a contra account owner" do
            transaction.contra_account_owner.should == "belastingdienst"
          end
        end

      end

      context "third bankstatement" do

        let(:bank_statement) { bank_statements_for_account[2] }

        it "has the correct previous balance" do
          balance = bank_statement.previous_balance
          balance.amount.should == 5666.09
          balance.date.should == Date.new(2014, 1, 13)
          balance.currency.should == "EUR"
        end

        it "has the correct next balance" do
          balance = bank_statement.new_balance
          balance.amount.should == 4849.34
          balance.date.should == Date.new(2014, 1, 22)
          balance.currency.should == "EUR"
        end

        context MT940::Transaction do
          let(:transaction) { bank_statement.transactions.first }

          it "should have a description" do
            transaction.description.should == "Ke nmerk: 1234.4321.0000.5555 Omschrijving: 123123444 01-01-2014  3 MND 8888888888 Servicecontract"
          end

          it "should have an account number" do
            transaction.bank_account.should == "878787878"
          end

          it "should have a contra account number" do
            transaction.contra_account.should == "676767676"
          end

          it "should have a contra account iban number" do
            transaction.contra_account_iban.should == "NL80RABO0676767676"
          end

          it "should have a contra account owner" do
            transaction.contra_account_owner.should == "BEN"
          end
        end


      end

    end

  end


  context "booking to private van lanschot account" do
    let(:file_name) { File.dirname(__FILE__) + '/fixtures/van_lanschot/to_private_account_86.txt' }
    let(:bank_statements) { MT940Structured::Parser.parse_mt940(file_name) }

    it "should have the correct number of bank account's" do
      bank_statements.keys.size.should == 1
    end

    it "should have the correct number of bank statements per bank account" do
      bank_statements["878787878"].size.should == 1
    end

    context MT940::BankStatement do
      let(:bank_statements_for_account) { bank_statements["878787878"] }

      it "should have the correct number of transactions per bank statement" do
        bank_statements_for_account[0].transactions.size.should == 1
      end

      context "first bankstatement" do

        let(:bank_statement) { bank_statements_for_account[0] }

        it "has the correct previous balance" do
          balance = bank_statement.previous_balance
          balance.amount.should == 2737.51
          balance.date.should == Date.new(2014, 2, 24)
          balance.currency.should == "EUR"
        end

        it "has the correct next balance" do
          balance = bank_statement.new_balance
          balance.amount.should == 2584.37
          balance.date.should == Date.new(2014, 3, 3)
          balance.currency.should == "EUR"
        end


        context MT940::Transaction do
          let(:transaction) { bank_statement.transactions.first }

          it "should have a description" do
            transaction.description.should == "A.B.C NAME declaratie 2014"
          end

          it "should have an account number" do
            transaction.bank_account.should == "878787878"
          end

          it "should have a contra account number" do
            transaction.contra_account.should == "111111110"
          end


        end

      end

    end

  end

  context "unspecified contra account" do
    let(:file_name) { File.dirname(__FILE__) + '/fixtures/van_lanschot/unspecified_contra_account.txt' }
    let(:bank_statements) { MT940Structured::Parser.parse_mt940(file_name) }

    it "should have the correct number of bank account's" do
      bank_statements.keys.size.should == 1
    end

    it "should have the correct number of bank statements per bank account" do
      bank_statements["878787878"].size.should == 1
    end

    context MT940::BankStatement do
      let(:bank_statements_for_account) { bank_statements["878787878"] }

      it "should have the correct number of transactions per bank statement" do
        bank_statements_for_account[0].transactions.size.should == 1
      end

      context "first bankstatement" do

        let(:bank_statement) { bank_statements_for_account[0] }

        it "has the correct previous balance" do
          balance = bank_statement.previous_balance
          balance.amount.should == 3592.00
          balance.date.should == Date.new(2014, 4, 1)
          balance.currency.should == "EUR"
        end

        it "has the correct next balance" do
          balance = bank_statement.new_balance
          balance.amount.should == 3571.08
          balance.date.should == Date.new(2014, 4, 3)
          balance.currency.should == "EUR"
        end


        context MT940::Transaction do
          let(:transaction) { bank_statement.transactions.first }

          it "should have a description" do
            transaction.description.should == "AAAAAAAAA SFDADSFG         asdfASDFASDF     ASDFASFAS ERIODE: 01-01-2014 / 31-03-2014"
          end

          it "should have an account number" do
            transaction.bank_account.should == "878787878"
          end

          it "should have a contra account number" do
            transaction.contra_account.should be_nil
          end


        end

      end

    end

  end
end
