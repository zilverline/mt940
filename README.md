MT940
======

[![Build Status](https://travis-ci.org/zilverline/mt940.svg)](https://travis-ci.org/zilverline/mt940)

Full parser for MT940 files, see [MT940](http://nl.wikipedia.org/wiki/MT940).
Initially this is based on the original gem of [Frank Oxener - Agile Dovadi BV](http://github.com/dovadi/mt940)
but as of version 2.0 completely rewritten in order to support MT940-structured format introduced by SEPA.

The following (Dutch) banks are implemented:

* ABN Amro
* ING
* Rabobank
* Triodos
* Knab
* van Lanschot
* SNS Reaal
* Deutsche Bank

Usage
=====

With the file name as argument:

    file_name = '~/Downloads/ing.940'

    @parse_result = MT940Structured::Parser.parse_mt940(file_name)

or with the file itself:

    file_name = '~/Downloads/ing.940'

    file = File.open(file_name)

    @parse_result = MT940Structured::Parser.parse_mt940(file)

after parsing:

    @parse_result.each do |account_number, bank_statements|
      puts "Account number #{account_number} has #{bank_statements.size} bank statements"
      bank_statements.each do |bank_statement|
        puts "Bank statement has balance of #{bank_statement.previous_balance.amount} at date #{bank_statement.previous_balance.date}"
        bank_statement.transactions.each do |transaction|
          # do something with transaction
          # ...
        end
        puts "Bank statement has new balance of #{bank_statement.new_balance.amount} at date #{bank_statement.new_balance.date}"
      end
    end

* Independent of the bank

  - a parse_result consists of:

    - a map with account numbers as key and a list of BankStatements (http://en.wikipedia.org/wiki/Bank_statement)
    - A BankStatement is a summary of financial transaction in a certain period of time.
      - It is a Struct
      - It contains a previous_balance (Balance) and a new_balance (Balance)
      - It has a list of Transactions
        - a transaction always consists of:
          - accountnumber
          - bank (for example Ing, Rabobank or Unknown)
          - date
          - amount (which is negative in case of a withdrawal)
          - description
          - contra account

* With the Rabobank its owner is extracted as well.

Running tests
=============

> bundle install

> bundle exec rake spec

Copyright
==========

Copyright (c) 2012 Frank Oxener - Agile Dovadi BV. See LICENSE.txt for further details.

