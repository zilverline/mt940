module MT940

  class Transaction

    attr_accessor :bank_account, :bank_account_iban, :contra_account, :contra_account_iban, :amount, :type, :description, :contra_account_owner, :date, :bank, :currency

    def initialize(attributes = {})
      @bank_account        = attributes[:bank_account]
      @bank_account_iban   = attributes[:bank_account_iban]
      @bank                = attributes[:bank]
      @amount              = attributes[:amount]
      @type                = attributes[:type]
      @description         = attributes[:description]
      @date                = attributes[:date]
      @contra_account      = attributes[:contra_account]
      @contra_account_iban = attributes[:contra_account_iban]
      @contra_account_owner = attributes[:contra_account_owner]
      @currency            = attributes[:currency]
    end

  end

end