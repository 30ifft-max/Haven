require "test_helper"

class CategoryGroupOnlyTest < ActiveSupport::TestCase
  test "a top-level category can be used only as a group" do
    category = categories(:food_and_drink)

    category.update!(group_only: true)

    assert category.group_only?
    assert_not category.selectable?
  end

  test "a subcategory cannot be used only as a group" do
    category = categories(:subcategory)

    category.group_only = true

    assert_not category.valid?
    assert_includes category.errors[:group_only], "is only available for top-level categories"
  end

  test "select options retain selectable children of a group-only parent" do
    parent = categories(:food_and_drink)
    child = categories(:subcategory)
    parent.update!(group_only: true)

    options = Category::Group.select_options([ parent, child ], selectable_only: true)

    assert_equal [ [ "↳ #{child.name}", child.id ] ], options
  end
end
