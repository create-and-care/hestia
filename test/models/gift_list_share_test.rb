require "test_helper"

class GiftListShareTest < ActiveSupport::TestCase
  test "generates a token on create when none is given" do
    share = gift_lists(:beta_list).create_gift_list_share!
    assert_match(/\A\S+\z/, share.token)
  end

  test "respects an explicitly provided token" do
    list = households(:alpha).gift_lists.create!(name: "Anniversaire", perspective: "receive")
    share = list.create_gift_list_share!(token: "CUSTOMTOKEN")
    assert_equal "CUSTOMTOKEN", share.token
  end

  test "requires a unique token" do
    share = GiftListShare.new(gift_list: gift_lists(:beta_list), token: gift_list_shares(:alpha_share).token)
    assert_not share.valid?
    assert_includes share.errors[:token], "has already been taken"
  end
end
