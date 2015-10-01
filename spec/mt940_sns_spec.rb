require_relative 'spec_helper'

describe "Sns" do

  let(:account_number) { "1234567809" }

  context "parse whole file" do
    let(:file_name) { File.dirname(__FILE__) + '/fixtures/sns/sns.txt' }
    let(:bank_statements) { MT940Structured::Parser.parse_mt940(file_name) }

    it "should have the correct number of bank account's" do
      expect(bank_statements.keys.size).to eq(1)
    end

    it "should have the correct number of bank statements per bank account" do
      expect(bank_statements[account_number].size).to eq(16)
    end

    context MT940::BankStatement do
      let(:bank_statements_for_account) { bank_statements[account_number] }

      it "should have the correct number of transactions per bank statement" do
        expect(bank_statements_for_account[0].transactions.size).to eq(1)
      end

      it "should have a correct previous balance per statement" do
        balance = bank_statements_for_account[0].previous_balance
        expect(balance.amount).to eq(534.03)
        expect(balance.date).to eq(Date.new(2014, 1, 19))
        expect(balance.currency).to eq("EUR")
      end

      it "should have a correct next balance per statement" do
        balance = bank_statements_for_account[0].new_balance
        expect(balance.amount).to eq(546.48)
        expect(balance.date).to eq(Date.new(2014, 1, 19))
        expect(balance.currency).to eq("EUR")
      end

      context MT940::Transaction do
        let(:transaction) { bank_statements[account_number].first.transactions.first }

        it "should have the correct amount" do
          expect(transaction.amount).to eq(12.45)
        end

        it "should have a description" do
          expect(transaction.description).to eq("creditrente                     01-01-13 tot 01-01-14")
        end

        it "should have an account number" do
          expect(transaction.bank_account).to eq(account_number)
        end

        it "should have a contra account number" do
          expect(transaction.contra_account).to eq("NONREF")
        end

        it "should have a contra account iban number" do
          expect(transaction.contra_account_iban).to be_nil
        end

        it "should have a contra account owner" do
          expect(transaction.contra_account_owner).to be_nil
        end

        it "should have a bank" do
          expect(transaction.bank).to eq("Sns")
        end

        it "should have a currency" do
          expect(transaction.currency).to eq("EUR")
        end

        it "should have a date" do
          expect(transaction.date).to eq(Date.new(2014, 1, 1))
        end

        it 'does not have a bank_reference' do
          expect(transaction.bank_reference).to eq ''
        end

        it 'does not have a customer_reference' do
          expect(transaction.customer_reference).to eq ''
        end

      end

      context "Another transaction" do
        let(:transaction) { bank_statements[account_number].last.transactions.first }

        it "should have the correct amount" do
          expect(transaction.amount).to eq(20000)
        end

        it "should have a description" do
          expect(transaction.description).to eq("366919158-nl11rabo0987654321-f. spark bedrijf n.v.")
        end

        it "should have an account number" do
          expect(transaction.bank_account).to eq(account_number)
        end

        it "should have a contra account number" do
          expect(transaction.contra_account).to eq("987654321")
        end

        it "should have a contra account iban number" do
          expect(transaction.contra_account_iban).to eq("NL11RABO0987654321")
        end

        it "should have a contra account owner" do
          expect(transaction.contra_account_owner).to eq("f. spark bedrijf n.v.")
        end

        it "should have a bank" do
          expect(transaction.bank).to eq("Sns")
        end

        it "should have a currency" do
          expect(transaction.currency).to eq("EUR")
        end

        it "should have a date" do
          expect(transaction.date).to eq(Date.new(2014, 9, 22))
        end

        it 'does not have a bank_reference' do
          expect(transaction.bank_reference).to eq ''
        end

        it 'does not have a customer_reference' do
          expect(transaction.customer_reference).to eq ''
        end

      end
    end

  end

  context 'parsing references' do
    let(:file_name) { File.dirname(__FILE__) + '/fixtures/sns/sns_customer_reference.txt' }
    let(:bank_statements) { MT940Structured::Parser.parse_mt940(file_name)['112233440'] }
    let(:transaction) { bank_statements.flat_map(&:transactions).first }

    it 'has a customer reference' do
      expect(transaction.customer_reference).to eq '0002445588'
    end

    it 'has a bank reference' do
      expect(transaction.bank_reference).to eq '1234432112344321'
    end
  end


end
