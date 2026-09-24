module Haven
  # Presentation only: collapse a matched transfer before pagination, but only
  # when its outflow also belongs to the already-authorized, filtered scope.
  # Totals continue to use the original search scope with both ledger entries.
  class TransactionList
    def self.call(scope)
      matching_ids = scope.reorder(nil).select(:id)
      hidden_inflows = Transfer.where(outflow_transaction_id: matching_ids).select(:inflow_transaction_id)
      scope.where.not(id: hidden_inflows)
    end
  end
end
