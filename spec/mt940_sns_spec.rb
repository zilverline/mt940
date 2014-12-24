require_relative 'spec_helper'

describe "Sns" do

  let(:account_number) { "1234567809" }

  context "parse whole file" do
    let(:file_name) { File.dirname(__FILE__) + '/fixtures/sns/sns.txt' }
    let(:bank_statements) { MT940Structured::Parser.parse_mt940(file_name) }

    it "should have the correct number of bank account's" do
      bank_statements.keys.size.should == 1
    end

    it "should have the correct number of bank statements per bank account" do
      bank_statements[account_number].size.should == 16
    end

    context MT940::BankStatement do
      let(:bank_statements_for_account) { bank_statements[account_number] }

      it "should have the correct number of transactions per bank statement" do
        bank_statements_for_account[0].transactions.size.should == 1
      end

      it "should have a correct previous balance per statement" do
        balance = bank_statements_for_account[0].previous_balance
        balance.amount.should == 534.03
        balance.date.should == Date.new(2014, 1, 19)
        balance.currency.should == "EUR"
      end

      it "should have a correct next balance per statement" do
        balance = bank_statements_for_account[0].new_balance
        balance.amount.should == 546.48
        balance.date.should == Date.new(2014, 1, 19)
        balance.currency.should == "EUR"
      end

      context MT940::Transaction do
        let(:transaction) { bank_statements[account_number].first.transactions.first }

        it "should have the correct amount" do
          transaction.amount.should == 12.45
        end

        it "should have a description" do
          transaction.description.should == "creditrente                     01-01-13 tot 01-01-14"
        end

        it "should have an account number" do
          transaction.bank_account.should == account_number
        end

        it "should have a contra account number" do
          transaction.contra_account.should == "NONREF"
        end

        it "should have a contra account iban number" do
          transaction.contra_account_iban.should be_nil
        end

        it "should have a contra account owner" do
          transaction.contra_account_owner.should be_nil
        end

        it "should have a bank" do
          transaction.bank.should == "Sns"
        end

        it "should have a currency" do
          transaction.currency.should == "EUR"
        end

        it "should have a date" do
          transaction.date.should == Date.new(2014, 1, 1)
        end

      end

      context "Another transaction" do
        let(:transaction) { bank_statements[account_number].last.transactions.first }

        it "should have the correct amount" do
          transaction.amount.should == 20000
        end

        it "should have a description" do
          transaction.description.should == "366919158-nl11rabo0987654321-f. spark bedrijf n.v."
        end

        it "should have an account number" do
          transaction.bank_account.should == account_number
        end

        it "should have a contra account number" do
          transaction.contra_account.should == "987654321"
        end

        it "should have a contra account iban number" do
          transaction.contra_account_iban.should == "NL11RABO0987654321"
        end

        it "should have a contra account owner" do
          transaction.contra_account_owner.should == "f. spark bedrijf n.v."
        end

        it "should have a bank" do
          transaction.bank.should == "Sns"
        end

        it "should have a currency" do
          transaction.currency.should == "EUR"
        end

        it "should have a date" do
          transaction.date.should == Date.new(2014, 9, 22)
        end

      end
    end

  end


end
