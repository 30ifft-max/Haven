module EntriesHelper
  SplitGroup = Data.define(:parent, :children)

  def group_split_entries(entries, split_parents)
    return entries if split_parents.blank?

    result = []
    seen_parent_ids = Set.new

    entries.each do |entry|
      if entry.split_child? && split_parents[entry.parent_entry_id]
        parent_id = entry.parent_entry_id
        next if seen_parent_ids.include?(parent_id)

        seen_parent_ids.add(parent_id)
        children = entries
          .select { |e| e.parent_entry_id == parent_id }
          .sort_by { |e| [ e.split_order.nil? ? 1 : 0, e.split_order || 0, e.created_at, e.id ] }
        result << SplitGroup.new(parent: split_parents[parent_id], children: children)
      else
        result << entry
      end
    end

    result
  end

  def entries_by_date(entries, totals: false)
    transfer_counts = Hash.new(0)
    entries.each do |entry|
      next unless entry.entryable_type == "Transaction"

      transfer = entry.entryable.transfer
      transfer_counts[transfer.id] += 1 if transfer
    end

    # Keep the query's ordering while hiding the duplicate inflow side when
    # both sides of a transfer are present in the current result set.
    deduped_entries = entries.reject do |entry|
      next false unless entry.entryable_type == "Transaction"

      transaction = entry.entryable
      transfer = transaction.transfer
      transfer && transfer_counts[transfer.id] > 1 && transaction.transfer_as_inflow.present?
    end

    deduped_entries.group_by(&:date).sort.reverse_each.map do |date, grouped_entries|
      content = capture do
        yield grouped_entries
      end

      next if content.blank?

      render partial: "entries/entry_group", locals: { date:, entries: grouped_entries, content:, totals: }
    end.compact.join.html_safe
  end

  def entry_name_detailed(entry)
    [
      entry.date,
      format_money(entry.amount_money),
      entry.account.name,
      entry.name
    ].join(" • ")
  end
end
