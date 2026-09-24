require "application_system_test_case"

class Haven::TransactionLogSystemTest < ApplicationSystemTestCase
  include EntriesTestHelper

  setup do
    @family = families(:empty)
    account = @family.accounts.create!(name: "Long source account for checking layout", balance: 0, currency: "USD", accountable: Depository.new)
    merchant = @family.merchants.create!(name: "Long merchant name for layout checks")
    category = @family.categories.create!(name: "Long category name", color: "#6471eb", lucide_icon: "shopping-cart")
    @usd = create_transaction(account: account, name: "Long transaction description for responsive column inspection", amount: 1_234_567.89, currency: "USD", merchant: merchant, category: category)
    @hkd = create_transaction(account: account, name: "HKD transaction", amount: 100, currency: "HKD")
    user = users(:empty)
    user.update!(locale: "en", show_ai_sidebar: false)
    visit new_session_path(locale: "en")
    within %(form[action='#{sessions_path}']) do
      fill_in "email", with: user.email
      fill_in "password", with: user_password_test
      find('[type="submit"]').click
    end
    assert_selector "h1", text: "Welcome back, #{user.first_name}"
    visit transactions_url
  end

  test "desktop search is visible, mobile search folds, and blur still submits" do
    assert_selector "#q_search"
    assert_operator find("#q_search").rect.width, :>=, 200
    page.current_window.resize_to(390, 844)
    assert_no_selector "#q_search"
    find(".haven-transaction-search summary").click
    assert_selector "#q_search"
    fill_in "q_search", with: "HKD transaction"
    find("#q_search").send_keys(:tab)
    assert_selector "##{dom_id(@hkd)}"
    assert_no_selector "##{dom_id(@usd)}"
    page.current_window.resize_to(1400, 1000)
    assert_selector "#q_search"
  end

  test "amount operator is exclusive and currency can be applied and removed" do
    find("#transaction-filters-button").click
    within "#transaction-filters-menu" do
      click_button "Amount"
      choose "Greater than"
      choose "Less than"
      assert_no_checked_field "Greater than"
      fill_in "q_amount_less", with: "2000000"
      check "Limit to one currency"
      select "HKD", from: "q_currency"
      click_button "Apply"
    end
    assert_selector "##{dom_id(@hkd)}"
    assert_no_selector "##{dom_id(@usd)}"
    find("#transaction-filters-button").click
    within "#transaction-filters-menu" do
      click_button "Amount"
      find('button[data-input-id="q_currency"]').click
      assert_no_checked_field "Limit to one currency"
      assert_selector "#q_currency[disabled]"
      click_button "Apply"
    end
    assert_selector "##{dom_id(@usd)}"
    assert_selector "##{dom_id(@hkd)}"
  end

  test "desktop columns stay aligned and overview expands below stationary toolbar" do
    [ 1024, 1280, 1440 ].each do |width|
      page.current_window.resize_to(width, 1000)
      assert_selector ".haven-transaction-row"
      measurements = page.evaluate_script(<<~JS)
        Array.from(document.querySelectorAll('.haven-transaction-log .haven-transaction-row')).map(row => ({
          width: row.clientWidth,
          scroll: row.scrollWidth,
          columns: Array.from(row.children).map(cell => ({left: cell.getBoundingClientRect().left, right: cell.getBoundingClientRect().right})),
          amountFits: row.lastElementChild.scrollWidth <= row.lastElementChild.clientWidth + 1
        }))
      JS
      measurements.each do |row|
        assert_operator row["scroll"], :<=, row["width"] + 1
        assert row["amountFits"], "Amount must fit at #{width}px"
        row["columns"].each_cons(2) { |a, b| assert_operator a["right"], :<=, b["left"] + 1 }
      end
      assert_in_delta measurements[0]["columns"].last["left"], measurements[1]["columns"].last["left"], 1
    end
    before = find("#transaction-summary-button").rect.y
    find("#transaction-summary-button").click
    assert_selector "#transaction-summary"
    assert_in_delta before, find("#transaction-summary-button").rect.y, 1
    assert_operator find("#transaction-summary").rect.y, :>, before
    save_screenshot Rails.root.join("tmp/screenshots/haven-transaction-log-desktop.png")
  end

  test "transaction log has category before merchant in the HTML while account activity keeps its order" do
    cells = page.evaluate_script(<<~JS)
      Array.from(document.querySelector('##{dom_id(@usd)} .haven-transaction-row').children)
        .map(cell => cell.textContent.trim())
    JS
    assert_includes cells[2], "Long category name"
    assert_includes cells[3], "Long merchant name for layout checks"

    visit account_path(@usd.account, tab: "transactions")
    assert_selector "##{dom_id(@usd)} .haven-transaction-row"
    cells = page.evaluate_script(<<~JS)
      Array.from(document.querySelector('##{dom_id(@usd)} .haven-transaction-row').children)
        .map(cell => cell.textContent.trim())
    JS
    assert_includes cells[2], "Long merchant name for layout checks"
    assert_includes cells[3], "Long category name"
  end
end
