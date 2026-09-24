module TransactionsHelper
  def transaction_search_filters
    [
      { key: "category_filter", label: t("transactions.search.filters.category"), icon: "shapes" },
      { key: "account_filter", label: t("transactions.search.filters.account"), icon: "layers" },
      { key: "merchant_filter", label: t("transactions.search.filters.merchant"), icon: "store" },
      { key: "tag_filter", label: t("transactions.search.filters.tag"), icon: "tags" },
      { key: "amount_filter", label: t("transactions.search.filters.amount"), icon: "hash" },
      { key: "type_filter", label: t("transactions.search.filters.type"), icon: "tag" },
      { key: "status_filter", label: t("transactions.search.filters.status"), icon: "clock" }
    ]
  end

  def get_transaction_search_filter_partial_path(filter)
    "transactions/searches/filters/#{filter[:key]}"
  end

  def get_default_transaction_search_filter
    transaction_search_filters[0]
  end

  def transaction_date_range_label(start_date, end_date)
    start_date = Date.parse(start_date.to_s)
    end_date = Date.parse(end_date.to_s)

    ranges = {
      "last_7_days" => [ Date.current - 6.days, Date.current ],
      "last_14_days" => [ Date.current - 13.days, Date.current ],
      "last_30_days" => [ Date.current - 29.days, Date.current ],
      "this_month" => [ Date.current.beginning_of_month, Date.current ],
      "last_month" => [ Date.current.last_month.beginning_of_month, Date.current.last_month.end_of_month ],
      "this_year" => [ Date.current.beginning_of_year, Date.current ],
      "last_year" => [ Date.current.last_year.beginning_of_year, Date.current.last_year.end_of_year ]
    }

    range_key = ranges.key([ start_date, end_date ])
    t("transactions.searches.date_menu.quick_ranges.#{range_key}") if range_key
  rescue Date::Error
    nil
  end

  def in_split_group?(entry, params_grouped)
    entry.split_child? && Current.user.show_split_grouped? && params_grouped == "true"
  end

  # ---- Transaction extra details helpers ----
  # Returns a structured hash describing extra details for a transaction.
  # Input can be a Transaction or an Entry (responds_to :transaction).
  # Structure:
  #   {
  #     kind: :simplefin | :raw,
  #     simplefin: { payee:, description:, memo: },
  #     provider_extras: [ { key:, value:, title: } ],
  #     raw: String (pretty JSON or string)
  #   }
  def build_transaction_extra_details(obj)
    tx = obj.respond_to?(:transaction) ? obj.transaction : obj
    return nil unless tx.respond_to?(:extra) && tx.extra.present?

    extra = tx.extra.deep_dup

    # The transaction form initializes exchange-rate metadata even when no
    # conversion is used. Keep that metadata for transfers, where it is
    # meaningful, but do not expose it as "additional details" for ordinary
    # income/expense transactions.
    unless tx.respond_to?(:transfer?) && tx.transfer?
      extra.delete("exchange_rate")
      extra.delete("exchange_rate_invalid")
    end

    return nil if extra.blank?

    if extra.is_a?(Hash) && extra["simplefin"].present?
      sf = extra["simplefin"]
      simple = {
        payee: sf.is_a?(Hash) ? sf["payee"].presence : nil,
        description: sf.is_a?(Hash) ? sf["description"].presence : nil,
        memo: sf.is_a?(Hash) ? sf["memo"].presence : nil
      }.compact

      extras = []
      if sf.is_a?(Hash) && sf["extra"].is_a?(Hash) && sf["extra"].present?
        sf["extra"].each do |k, v|
          display = (v.is_a?(Hash) || v.is_a?(Array)) ? v.to_json : v
          extras << {
            key: k.to_s.humanize,
            value: display,
            title: (v.is_a?(String) ? v : display.to_s)
          }
        end
      end

      {
        kind: :simplefin,
        simplefin: simple,
        provider_extras: extras,
        raw: nil
      }
    else
      pretty = begin
        JSON.pretty_generate(extra)
      rescue StandardError
        extra.to_s
      end
      {
        kind: :raw,
        simplefin: {},
        provider_extras: [],
        raw: pretty
      }
    end
  end
end
