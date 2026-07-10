require "test_helper"

class Ui::CarouselComponentTest < ViewComponent::TestCase
  test "renders one track item per slide, containing the slide's content" do
    render_inline(Ui::CarouselComponent.new) do |carousel|
      carousel.with_slide { "First slide" }
      carousel.with_slide { "Second slide" }
      carousel.with_slide { "Third slide" }
    end

    assert_selector "div[data-controller='carousel']"
    assert_selector "div[data-carousel-target='track']"
    assert_selector "div[data-carousel-target='item']", count: 3
    assert_text "First slide"
    assert_text "Second slide"
    assert_text "Third slide"
  end

  test "renders one dot per slide indexed for the goTo action" do
    render_inline(Ui::CarouselComponent.new) do |carousel|
      carousel.with_slide { "A" }
      carousel.with_slide { "B" }
    end

    assert_selector "button[data-carousel-target='dot'][data-action='click->carousel#goTo']", count: 2
    assert_selector "button[data-carousel-target='dot'][data-index='0'][aria-label='Go to slide 1']"
    assert_selector "button[data-carousel-target='dot'][data-index='1'][aria-label='Go to slide 2']"
  end

  test "renders previous/next controls with accessible labels" do
    render_inline(Ui::CarouselComponent.new) do |carousel|
      carousel.with_slide { "Only slide" }
    end

    assert_selector "button[data-action='click->carousel#previous'][aria-label='Previous slide']"
    assert_selector "button[data-action='click->carousel#next'][aria-label='Next slide']"
  end

  test "exposes the root as an accessible carousel region with a live region for slide changes" do
    render_inline(Ui::CarouselComponent.new) do |carousel|
      carousel.with_slide { "First slide" }
      carousel.with_slide { "Second slide" }
    end

    assert_selector "div[data-controller='carousel'][role='region'][aria-roledescription='carousel']"
    assert_selector "div[data-carousel-target='status'][aria-live='polite']", visible: :all
  end

  test "dots expose their active state via aria-current for assistive tech" do
    render_inline(Ui::CarouselComponent.new) do |carousel|
      carousel.with_slide { "A" }
      carousel.with_slide { "B" }
    end

    assert_selector "button[data-carousel-target='dot'][aria-current]", count: 2
  end

  test "renders with no slides without raising" do
    render_inline(Ui::CarouselComponent.new)

    assert_selector "div[data-controller='carousel']"
    assert_no_selector "div[data-carousel-target='item']"
    assert_no_selector "button[data-carousel-target='dot']"
  end
end
