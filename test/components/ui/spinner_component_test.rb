require "test_helper"

class Ui::SpinnerComponentTest < ViewComponent::TestCase
  test "renders default spinner with accessible status role and label" do
    render_inline(Ui::SpinnerComponent.new)

    assert_selector "svg.animate-spin[role='status'][aria-label='Loading']"
  end

  test "renders every size with its distinguishing class" do
    Ui::SpinnerComponent::SIZES.each_key do |size|
      render_inline(Ui::SpinnerComponent.new(size: size))

      fragment = Ui::SpinnerComponent::SIZES.fetch(size)
      assert_selector "svg.#{fragment}"
    end
  end

  test "renders the spinning circle and path" do
    render_inline(Ui::SpinnerComponent.new)

    assert_selector "svg circle"
    assert_selector "svg path"
  end
end
