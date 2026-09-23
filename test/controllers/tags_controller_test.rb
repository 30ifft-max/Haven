require "test_helper"

class TagsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in @user = users(:family_admin)
    @other_family_user = users(:empty)

    # Verify cross-family isolation setup is correct
    assert_not_equal @user.family_id, @other_family_user.family_id,
      "Test setup error: @other_family_user must belong to a different family"
  end

  test "should get index" do
    get tags_url
    assert_response :success

    @user.family.tags.each do |tag|
      assert_select "#" + dom_id(tag), count: 1
    end
  end

  test "index shows each tag's usage count" do
    tag = @user.family.tags.first
    initial_usage_count = tag.taggings.count
    transaction = Transaction.create!(tag_ids: [ tag.id ])
    Entry.create!(
      account: @user.family.accounts.first,
      entryable: transaction,
      name: "Tagged transaction",
      date: Date.current,
      amount: 10,
      currency: @user.family.currency
    )

    get tags_url

    assert_response :success
    assert_select "##{dom_id(tag)} [data-testid='tag-usage-count']",
                  text: "· #{initial_usage_count + 1}"
  end

  test "should get new" do
    get new_tag_url
    assert_response :success
  end

  test "should create tag" do
    assert_difference("Tag.count") do
      post tags_url, params: { tag: { name: "Test Tag" } }
    end

    assert_redirected_to tags_url
    assert_equal "Tag created", flash[:notice]
  end

  test "should create tag as json" do
    assert_difference("Tag.count") do
      post tags_url(format: :json), params: { tag: { name: "Quick Tag", color: "#e99537" } }
    end

    assert_response :created

    response_body = JSON.parse(response.body)
    assert_equal "Quick Tag", response_body["name"]
    assert_equal "#e99537", response_body["color"]
    assert response_body["id"].present?
    assert_includes response_body["html"], "data-tag-select-target=\"option\""
    assert_includes response_body["html"], "data-tag-id=\"#{response_body["id"]}\""
    assert_includes response_body["html"], "data-tag-select-badge"
  end

  test "should return json validation errors" do
    assert_no_difference("Tag.count") do
      post tags_url(format: :json), params: { tag: { name: "" } }
    end

    assert_response :unprocessable_entity
    assert JSON.parse(response.body)["errors"].present?
  end

  test "should get edit" do
    get edit_tag_url(tags.first)
    assert_response :success
  end

  test "should update tag" do
    patch tag_url(tags.first), params: { tag: { name: "Test Tag" } }

    assert_redirected_to tags_url
    assert_equal "Tag updated", flash[:notice]
  end
end
