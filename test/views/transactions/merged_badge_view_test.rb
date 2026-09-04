require "test_helper"

class Transactions::MergedBadgeViewTest < ActionView::TestCase
  # Render the transactions/_transaction partial and verify the merged badge does not appear
  test "does not render merged badge after was_merged column removal" do
    account = accounts(:depository)

    transaction = Transaction.create!
    entry = Entry.create!(
      account: account,
      entryable: transaction,
      name: "Cafe",
      amount: -987,
      currency: "USD",
      date: Date.today
    )

    html = render(partial: "transactions/transaction", locals: { entry: entry, balance_trend: nil, view_ctx: "global" })

    assert_not_includes html, "Merged from pending to posted", "Merged badge should no longer be shown in UI"
  end

  test "grouped split child uses its leading hierarchy marker and keeps its status column" do
    account = accounts(:depository)
    parent = Entry.create!(
      account: account,
      entryable: Transaction.create!,
      name: "Split purchase",
      amount: 100,
      currency: "USD",
      date: Date.current
    )
    child = parent.split!([ { name: "Split item", amount: 100, category_id: nil } ]).first

    html = render(partial: "transactions/transaction", locals: {
      entry: child,
      balance_trend: nil,
      view_ctx: "global",
      in_split_group: true
    })

    assert_includes html, "col-span-3 min-w-0"
    assert_not_includes html, "col-span-3 min-w-0 pl-8"
    assert_not_includes html, "border-l border-secondary"
    assert_includes html, I18n.t("transactions.transaction.split_child_tooltip")
    assert_operator html.index(I18n.t("transactions.transaction.split_child_tooltip")), :<, html.index("Split item")
    assert_includes html, "hidden lg:flex items-center gap-2 col-span-2 text-secondary"
  end

  test "split parent row does not render a circular merchant or fallback icon" do
    account = accounts(:depository)
    parent = Entry.create!(
      account: account,
      entryable: Transaction.create!,
      name: "Split purchase",
      amount: 100,
      currency: "USD",
      date: Date.current
    )
    parent.split!([ { name: "Split item", amount: 100, category_id: nil } ])
    parent.update!(notes: "Original split note")

    html = render(partial: "transactions/split_parent_row", locals: { entry: parent })

    assert_not_includes html, "w-9 h-9 rounded-full"
    assert_not_includes html, "w-4 shrink-0"
    assert_not_includes html, "text-xs font-normal"
    assert_not_includes html, account.name
    assert_includes html, "hidden lg:flex items-center gap-2 col-span-2 text-secondary"
    assert_includes html, "Original split note"
  end
end
