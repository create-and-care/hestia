require "test_helper"

class PreparedDishesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create" do
    assert_difference -> { households(:alpha).prepared_dishes.count }, 1 do
      post prepared_dishes_path,
        params: { prepared_dish: { name: "Curry", location: "congelateur", expires_on: Date.current + 30 } },
        as: :turbo_stream
    end
    assert_response :success
  end

  test "create attaches an optional photo" do
    photo = fixture_file_upload("sample.png", "image/png")
    post prepared_dishes_path,
      params: { prepared_dish: { name: "Quiche", location: "refrigerateur", photo: photo } },
      as: :turbo_stream
    assert households(:alpha).prepared_dishes.find_by!(name: "Quiche").photo.attached?
  end

  test "destroy" do
    dish = prepared_dishes(:alpha_lasagna)
    delete prepared_dish_path(dish), as: :turbo_stream
    assert_response :success
    assert_not PreparedDish.exists?(dish.id)
  end
end
