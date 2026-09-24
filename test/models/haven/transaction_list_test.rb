require "test_helper"

class Haven::TransactionListTest < ActiveSupport::TestCase
  include EntriesTestHelper

  setup do
    @family = families(:empty)
    @source = @family.accounts.create!(name: "Source", balance: 0, currency: "USD", accountable: Depository.new)
    @destination = @family.accounts.create!(name: "Destination", balance: 0, currency: "USD", accountable: Depository.new)
    @transfer = create_transfer(from_account: @source, to_account: @destination, amount: 123).reload
  end

  test "collapses both matching legs before limit and offset without changing ledger or search" do
    search = Transaction::Search.new(@family)
    original_ids = search.transactions_scope.pluck(:id)
    rows = Haven::TransactionList.call(search.transactions_scope)

    assert_equal [ @transfer.outflow_transaction_id ], rows.limit(1).pluck(:id)
    assert_empty rows.offset(1).limit(1)
    assert_equal 1, rows.count
    assert_equal original_ids.sort, search.transactions_scope.pluck(:id).sort
    assert_equal 2, search.totals.count
  end

  test "keeps inflow when outflow does not match account or text filters" do
    [ { account_ids: [ @destination.id ] }, { search: "Transfer from" } ].each do |filters|
      scope = Transaction::Search.new(@family, filters: filters).transactions_scope
      assert_equal [ @transfer.inflow_transaction_id ], Haven::TransactionList.call(scope).pluck(:id)
    end
  end

  test "keeps inflow when outflow falls outside the date range" do
    @transfer.outflow_transaction.entry.update!(date: Date.current - 2.days)
    scope = Transaction::Search.new(@family, filters: { start_date: Date.current.to_s }).transactions_scope
    assert_equal [ @transfer.inflow_transaction_id ], Haven::TransactionList.call(scope).pluck(:id)
  end

  test "does not drop accessible inflow when source account is inaccessible" do
    scope = Transaction::Search.new(@family, accessible_account_ids: [ @destination.id ]).transactions_scope
    assert_equal [ @transfer.inflow_transaction_id ], Haven::TransactionList.call(scope).pluck(:id)
    empty_scope = Transaction::Search.new(@family, accessible_account_ids: []).transactions_scope
    assert_empty Haven::TransactionList.call(empty_scope)
  end

  test "does not collapse unrelated or unmatched transactions" do
    ordinary = create_transaction(account: @source)
    unmatched = create_transaction(account: @source, kind: "funds_movement")
    scope = Transaction::Search.new(@family).transactions_scope
    assert_equal [ @transfer.outflow_transaction_id, ordinary.entryable_id, unmatched.entryable_id ].sort,
      Haven::TransactionList.call(scope).pluck(:id).sort
  end
end
