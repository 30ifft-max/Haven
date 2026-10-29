require "application_system_test_case"

class TransactionCategorySelectTest < ApplicationSystemTestCase
  setup do
    sign_in @user = users(:family_admin)
  end

  test "can create a category from the transaction form" do
    visit new_transaction_url

    assert_difference "Category.count", +1 do
      find("[data-controller='category-select'] button").click

      within "[data-controller='category-select']" do
        fill_in "Search categories", with: "Inline Test Category"

        assert_text 'Create "Inline Test Category"'
        click_button 'Create "Inline Test Category"'

        assert_selector(
          "[data-category-select-target='option'][aria-selected='true']",
          text: "Inline Test Category",
          visible: :all
        )
      end
    end

    assert Category.exists?(name: "Inline Test Category")
  end

  test "category search follows the account field in the Tab order and menu escapes dialog clipping" do
    visit new_transaction_url

    account = find("#account_id_trigger")
    account.send_keys(:tab)
    assert_selector "#account_id_trigger[aria-expanded='true']"

    account.send_keys(:tab)
    amount = find("input[type='number'][placeholder='100']")
    assert_equal amount[:id], page.evaluate_script("document.activeElement.id")
    amount.send_keys(:tab)

    assert_equal "category_id_trigger", page.evaluate_script("document.activeElement.id")
    assert_selector "#category_id_trigger[aria-expanded='true']"
    assert_selector "[data-category-select-target='search']", focused: true

    menu = find("[data-category-select-target='menu']")
    assert_equal "fixed", menu.evaluate_script("getComputedStyle(this).position")
    assert_operator menu.evaluate_script("this.getBoundingClientRect().bottom"), :<=, page.evaluate_script("window.innerHeight")
  end

  test "can clear a category from an existing transaction" do
    transaction = transactions(:one)
    transaction.update!(category: categories(:food_and_drink))
    entry = transaction.entry

    visit transactions_url

    page.execute_script <<~JS
      const frame = document.querySelector("turbo-frame#drawer")
      frame.src = "#{transaction_url(entry)}"
    JS

    within "turbo-frame#drawer", visible: :all do
      assert_selector "[data-controller='category-select']"

      within "[data-controller='category-select']" do
        find("button", match: :first).click
        find("button[data-category-id='']").click
      end
    end

    assert_selector(
      "##{ActionView::RecordIdentifier.dom_id(entry)}",
      text: "Uncategorized"
    )

    assert_nil transaction.reload.category_id
  end
end
