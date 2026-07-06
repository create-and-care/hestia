require "test_helper"

class GiftListTest < ActiveSupport::TestCase
  test "requires a name" do
    list = households(:alpha).gift_lists.build(perspective: "receive")
    assert_not list.valid?
    list.name = "Noël"
    assert list.valid?
  end

  test "requires a valid perspective" do
    list = households(:alpha).gift_lists.build(name: "Noël", perspective: "invalid")
    assert_not list.valid?
  end

  test "shared? reflects the presence of a gift_list_share" do
    assert gift_lists(:alpha_wishlist).shared?
    assert_not gift_lists(:beta_list).shared?
  end

  test "destroying a list destroys its share and ideas" do
    list = gift_lists(:alpha_wishlist)
    assert_difference [ "GiftListShare.count", "GiftIdea.count" ], -1 do
      list.destroy
    end
  end

  test "is scoped to its household" do
    assert_not_includes households(:alpha).gift_lists, gift_lists(:beta_list)
  end
end
