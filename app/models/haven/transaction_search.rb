module Haven
  # Optional original-currency filter for the web transaction log. Reuses Sure's
  # search and totals without changing ledger values or converting currencies.
  class TransactionSearch < Transaction::Search
    attribute :currency, :string

    def transactions_scope
      @currency_scope ||= super.where(entries: { currency: currency })
    end
  end
end
