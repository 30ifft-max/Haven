module CategoriesHelper
  def transfer_category
    Category.new \
      name: I18n.t("categories.virtual.transfer"),
      color: Category::TRANSFER_COLOR,
      lucide_icon: "arrow-right-left"
  end

  def payment_category
    Category.new \
      name: I18n.t("categories.virtual.payment"),
      color: Category::PAYMENT_COLOR,
      lucide_icon: "arrow-right"
  end

  def asset_transfer_category
    Category.new \
      name: I18n.t("categories.virtual.asset_transfer"),
      color: Category::TRANSFER_COLOR,
      lucide_icon: "arrow-right-left"
  end

  def liability_repayment_category
    Category.new \
      name: I18n.t("categories.virtual.liability_repayment"),
      color: Category::PAYMENT_COLOR,
      lucide_icon: "arrow-right"
  end

  def transfer_classification_category(transfer)
    transfer.effective_classification == "liability_repayment" ? liability_repayment_category : asset_transfer_category
  end

  def trade_category
    Category.new \
      name: I18n.t("categories.virtual.trade"),
      color: Category::TRADE_COLOR
  end

  def family_categories
    [ Category.uncategorized ].concat(Current.family.categories.selectable.alphabetically_by_hierarchy)
  end
end
