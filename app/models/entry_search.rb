class EntrySearch
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :search, :string
  attribute :amount, :string
  attribute :amount_operator, :string
  attribute :amount_min, :string
  attribute :amount_max, :string
  attribute :types, :string
  attribute :status, array: true
  attribute :accounts, array: true
  attribute :account_ids, array: true
  attribute :start_date, :string
  attribute :end_date, :string

  class << self
    def apply_search_filter(scope, search)
      return scope if search.blank?

      query = scope
      query = query.where("entries.name ILIKE :search OR entries.notes ILIKE :search",
        search: "%#{ActiveRecord::Base.sanitize_sql_like(search)}%"
      )
      query
    end

    def apply_date_filters(scope, start_date, end_date)
      return scope if start_date.blank? && end_date.blank?

      query = scope
      query = query.where("entries.date >= ?", start_date) if start_date.present?
      query = query.where("entries.date <= ?", end_date) if end_date.present?
      query
    end

    def apply_amount_filter(scope, amount, amount_operator, amount_min: nil, amount_max: nil)
      return scope if amount_operator.blank?

      query = scope

      case amount_operator
      when "equal"
        return scope if amount.blank?
        query = query.where("ABS(ABS(entries.amount) - ?) <= 0.01", amount.to_f.abs)
      when "less"
        return scope if amount.blank?
        query = query.where("ABS(entries.amount) < ?", amount.to_f.abs)
      when "greater"
        return scope if amount.blank?
        query = query.where("ABS(entries.amount) > ?", amount.to_f.abs)
      when "between"
        return scope if amount_min.blank? || amount_max.blank?

        lower, upper = [ BigDecimal(amount_min).abs, BigDecimal(amount_max).abs ].sort
        query = query.where("ABS(entries.amount) BETWEEN ? AND ?", lower, upper)
      else
        return scope
      end

      query
    rescue ArgumentError
      scope
    end

    def apply_accounts_filter(scope, accounts, account_ids)
      return scope if accounts.blank? && account_ids.blank?

      query = scope
      query = query.where(accounts: { name: accounts }) if accounts.present?
      query = query.where(accounts: { id: account_ids }) if account_ids.present?
      query
    end

    def apply_status_filter(scope, statuses)
      return scope unless statuses.present?
      return scope if statuses.uniq.sort == %w[confirmed pending] # Both selected = no filter

      # Source the pending check from Transaction::PENDING_CHECK_SQL (aliased to
      # "t") so every provider in PENDING_PROVIDERS is covered. Previously this
      # hardcoded only simplefin/plaid/lunchflow, dropping enable_banking.
      pending_condition = <<~SQL.squish
        entries.entryable_type = 'Transaction'
        AND EXISTS (
          SELECT 1 FROM transactions t
          WHERE t.id = entries.entryable_id
          AND (#{Transaction::PENDING_CHECK_SQL})
        )
      SQL

      confirmed_condition = <<~SQL.squish
        entries.entryable_type != 'Transaction'
        OR NOT EXISTS (
          SELECT 1 FROM transactions t
          WHERE t.id = entries.entryable_id
          AND (#{Transaction::PENDING_CHECK_SQL})
        )
      SQL

      case statuses.sort
      when [ "pending" ]
        scope.where(pending_condition)
      when [ "confirmed" ]
        scope.where(confirmed_condition)
      else
        scope
      end
    end
  end

  def build_query(scope)
    query = scope.joins(:account)
    query = self.class.apply_search_filter(query, search)
    query = self.class.apply_date_filters(query, start_date, end_date)
    query = self.class.apply_amount_filter(query, amount, amount_operator, amount_min: amount_min, amount_max: amount_max)
    query = self.class.apply_accounts_filter(query, accounts, account_ids)
    query = self.class.apply_status_filter(query, status)
    query
  end
end
