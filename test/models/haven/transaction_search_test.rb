require "test_helper"

class Haven::TransactionSearchTest < ActiveSupport::TestCase
  include EntriesTestHelper

  setup do
    @family = families(:empty)
    @account = @family.accounts.create!(name: "Multi currency", balance: 0, currency: "USD", accountable: Depository.new)
    @usd = create_transaction(account: @account, amount: 100, currency: "USD")
    @hkd = create_transaction(account: @account, amount: 100, currency: "HKD")
  end

  test "filters original entry currency without conversion and reuses totals" do
    search = Haven::TransactionSearch.new(@family, filters: { currency: "HKD", amount_operator: "equal", amount: "100" })
    assert_equal [ @hkd.entryable_id ], search.transactions_scope.pluck(:id)
    assert_equal 1, search.totals.count
    assert_equal [ "HKD" ], search.totals.expense_by_currency.keys
    assert_equal Money.new(100, "HKD"), search.totals.expense_by_currency["HKD"]
    usd_search = Haven::TransactionSearch.new(@family, filters: { currency: "USD", amount_operator: "equal", amount: "100" })
    assert_not_equal search.cache_key_base, usd_search.cache_key_base
  end

  test "base search retains all currencies and scopes remain authorized" do
    assert_equal [ @usd.entryable_id, @hkd.entryable_id ].sort,
      Transaction::Search.new(@family, filters: { amount_operator: "equal", amount: "100" }).transactions_scope.pluck(:id).sort
    assert_empty Haven::TransactionSearch.new(@family, filters: { currency: "HKD" }, accessible_account_ids: []).transactions_scope
    assert_empty Haven::TransactionSearch.new(families(:dylan_family), filters: { currency: "HKD" }).transactions_scope.where(id: @hkd.entryable_id)
  end

  test "currency-filtered transfer retains the matching side" do
    destination = @family.accounts.create!(name: "HKD", balance: 0, currency: "HKD", accountable: Depository.new)
    transfer = create_transfer(from_account: @account, to_account: destination, amount: 100)
    transfer.inflow_transaction.reload.entry.update!(currency: "HKD", amount: -780)
    scope = Haven::TransactionSearch.new(@family, filters: { currency: "HKD", types: [ "transfer" ] }).transactions_scope
    assert_equal [ transfer.inflow_transaction_id ], Haven::TransactionList.call(scope).pluck(:id)
  end
end
