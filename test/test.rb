require 'lib/markabee'
require 'test/unit'

class MarkabeeTest < Test::Unit::TestCase
  include Markabee

  def test_basic_block
    ele = Builder.new { html "foo" }
    assert_equal ele.to_s, "<html>foo</html>"
  end

  def test_self_closing
    ele = Builder.new { br }
    assert_equal ele.to_s, '<br />'
  end

  def test_attributes
    ele = Builder.new { form id: "test", method: "post" }
    assert_equal ele.to_s, '<form id="test" method="post"></form>'
  end

  def test_classes
    ele = Builder.new { p.foo "Hello." }
    assert_equal ele.to_s, '<p class="foo">Hello.</p>'
  end

  def test_multi_classes
    ele = Builder.new { p.foo.bar "Hello." }
    assert_equal ele.to_s, '<p class="foo bar">Hello.</p>'
  end

  def test_multi_classes_attr
    ele = Builder.new { p.foo.bar :class => "baz" do "Hello." end }
    assert_equal ele.to_s, '<p class="foo bar baz">Hello.</p>'
  end

  def test_nesting
    ele = Builder.new { div { div { div { p { div { "foo" } } } } } }
    assert_equal ele.to_s, "<div><div><div><p><div>foo</div></p></div></div></div>"
  end

  def test_nesting_sequence
    ele = Builder.new do
      ul do
        li "Item 1."
        li "Item 2."
        li "Item 3."
      end
    end
    assert_equal ele.to_s, "<ul><li>Item 1.</li><li>Item 2.</li><li>Item 3.</li></ul>"
  end

  def test_dynamic
    ele = Builder.new do
      ul do
        (1..3).each do |n|
          li "Item #{n}."
        end
      end
    end
    assert_equal ele.to_s, "<ul><li>Item 1.</li><li>Item 2.</li><li>Item 3.</li></ul>"
  end

  def test_doctype
    ele = Builder.new do
      html5
      html do
        body "Hello."
      end
    end

    assert_equal ele.to_s, "<!DOCTYPE html><html><body>Hello.</body></html>"
  end

  def test_big
    ele = Builder.new do
      html5
      html do
        head do
          title "a"
          link rel: "b", type: "c", href: "d"
        end

        body do
          div.e.f.g :class => "h", id: "i" do
            "j"
          end
        end
      end
    end

    assert_equal ele.to_s, '<!DOCTYPE html><html><head><title>a</title><link rel="b" type="c" href="d" /></head><body><div class="e f g h" id="i">j</div></body></html>'
  end
end
