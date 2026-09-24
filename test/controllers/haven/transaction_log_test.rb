require "test_helper"

class Haven::TransactionLogTest < ActionDispatch::IntegrationTest
  include EntriesTestHelper

  setup do
    sign_in users(:empty)
    @family = families(:empty)
    @account = @family.accounts.create!(name: "Source", balance: 0, currency: "USD", accountable: Depository.new)
  end

  test "pagination collapses transfer crossing the original page boundary" do
    destination = @family.accounts.create!(name: "Destination", balance: 0, currency: "USD", accountable: Depository.new)
    transfer = create_transfer(from_account: @account, to_account: destination, amount: 123, date: Date.current - 1.day)
    expenses = 30.times.map { |i| create_transaction(account: @account, date: Date.current, name: "Expense #{i}") }
    transfer.inflow_transaction.reload.entry.update!(date: Date.current + 1.day)
    all_ids = []
    [ 1, 2 ].each do |page|
      get transactions_url(page: page, per_page: 30)
      assert_response :success
      ids = css_select("turbo-frame[id^='entry_']").map { |node| node["id"] }
      assert_equal(page == 1 ? 30 : 1, ids.length)
      all_ids.concat(ids)
    end
    expected = (expenses + [ transfer.outflow_transaction.entry ]).map { |entry| dom_id(entry) }
    assert_equal expected.sort, all_ids.sort
  end

  test "currency selection narrows results and survives search and session restoration" do
    usd = create_transaction(account: @account, currency: "USD", amount: 100)
    hkd = create_transaction(account: @account, currency: "HKD", amount: 100)
    get transactions_url(q: { currency: "HKD", amount_operator: "equal", amount: "100" })
    assert_response :success
    assert_select "##{dom_id(hkd)}"
    assert_select "##{dom_id(usd)}", count: 0
    assert_select "select[name='q[currency]']:not([disabled]) option[selected]", text: "HKD"
    assert_select "input[name='q[amount_operator]'][type='radio']", count: 4
    assert_select "input[name='q[amount_operator]'][type='checkbox']", count: 0
    get transactions_url
    assert_response :redirect
    follow_redirect!
    assert_select "##{dom_id(hkd)}"
    assert_select "##{dom_id(usd)}", count: 0
    get transactions_url(q: { amount_operator: "equal", amount: "100" })
    assert_select "##{dom_id(usd)}"
    assert_select "##{dom_id(hkd)}"
    assert_select "select[name='q[currency]'][disabled]"
  end

  test "quick ranges include exactly their named number of dates and match button label" do
    travel_to Time.zone.local(2026, 9, 24, 12) do
      [ 7, 14, 30 ].each do |days|
        start_date = Date.current - (days - 1).days
        get transactions_url(q: { start_date: start_date.to_s, end_date: Date.current.to_s })
        assert_response :success
        assert_select "#transaction-date-button", text: I18n.t("transactions.searches.date_menu.quick_ranges.last_#{days}_days")
        assert_select "button[data-transaction-date-filter-start-value='#{start_date}'][data-transaction-date-filter-end-value='#{Date.current}']"
      end
      inside = create_transaction(account: @account, date: Date.current - 6.days)
      outside = create_transaction(account: @account, date: Date.current - 7.days)
      get transactions_url(q: { start_date: (Date.current - 6.days).to_s, end_date: Date.current.to_s })
      assert_select "##{dom_id(inside)}"
      assert_select "##{dom_id(outside)}", count: 0
    end
  end

  test "overview follows toolbar with recurring transactions enabled or disabled" do
    [ false, true ].each do |disabled|
      @family.update!(recurring_transactions_disabled: disabled)
      get transactions_url(clear_filters: true)
      assert_response :success
      assert_operator response.body.index('id="transactions-search"'), :<, response.body.index('id="transaction-summary"')
      assert_select "#transaction-summary ~ #transactions, #transaction-summary ~ div #transactions", count: 1
    end
  end
end
