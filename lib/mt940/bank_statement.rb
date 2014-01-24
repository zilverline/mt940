module MT940
  ##
  # A Bankstatement contains a single or multiple Transaction's.
  # It is the equivalent of an actual real life gold old paper bank statement
  # as we used to get them via post in the old days.
  #
  BankStatement = Struct.new(:transactions, :bank_account, :bank_account_iban, :page_number, :previous_balance, :new_balance)

  ##
  # A Balance describes the amount of money you have on your bank account
  # at a certain moment in time.
  Balance = Struct.new(:amount, :date, :currency)
end
