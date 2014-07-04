module MT940

  class Transaction

    attr_accessor :customer_reference, :bank_reference, :bank_account, :bank_account_iban, :contra_account, :contra_bank_code, :contra_account_iban, :contra_bic, :amount, :type, :sepa_business_code, :description, :contra_account_owner, :date, :date_accounting, :bank, :currency, :eref

    def initialize(attributes = {})
      @customer_reference   = attributes[:customer_reference]
      @bank_reference       = attributes[:bank_reference]
      @bank_account         = attributes[:bank_account]
      @bank_account_iban    = attributes[:bank_account_iban]
      @bank                 = attributes[:bank]
      @amount               = attributes[:amount]
      @type                 = attributes[:type]
      @sepa_business_code   = attributes[:sepa_business_code]
      @description          = attributes[:description]
      @date                 = attributes[:date]
      @date_accounting      = attributes[:date_accounting]
      @contra_account       = attributes[:contra_account]
      @contra_bank_code     = attributes[:contra_bank_code]
      @contra_account_iban  = attributes[:contra_account_iban]
      @contra_bic           = attributes[:contra_bic]
      @contra_account_owner = attributes[:contra_account_owner]
      @currency             = attributes[:currency]
      @eref                 = attributes[:eref]
    end

  end

end
