require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "name is unique per household, case-insensitively" do
    duplicate = households(:alpha).products.build(name: "lait")
    assert_not duplicate.valid?
  end

  test "the same name is allowed in a different household" do
    product = households(:beta).products.build(name: "Lait")
    assert product.valid?
  end
end
