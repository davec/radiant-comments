require File.dirname(__FILE__) + '/../spec_helper'

describe Page do
  dataset :users_and_pages, :comments
  
  describe "r:comments:field:spam_answer_tag" do
    it "should render the spam_answer input and the valid_spam_answer hidden input" do
      answer_as_set = 'no spam'
      correct_answer = Digest::MD5.hexdigest(answer_as_set.to_slug)
      pages(:home).should render("<r:comments:field:spam_answer_tag answer='#{answer_as_set}' />").as(%{<input type="text" id="comment_spam_answer" name="comment[spam_answer]" value=""  /><input type="hidden" name="comment[valid_spam_answer]" value="#{correct_answer}" />})
    end
  end

  describe "simple_spam_filter_required is true" do
    before do
      Radiant::Config['comments.simple_spam_filter_required?'] = true
    end

    describe "r:if_comments_use_simple_spam_filter" do
      it "should render the content" do
        tag = %{<r:if_comments_use_simple_spam_filter>foo</r:if_comments_use_simple_spam_filter>}
        expected = 'foo'
        pages(:home).should render(tag).as(expected)
      end
    end
    describe "r:unless_comments_use_simple_spam_filter" do
      it "should not render the content" do
        tag = %{<r:unless_comments_use_simple_spam_filter>foo</r:unless_comments_use_simple_spam_filter>}
        expected = ''
        pages(:home).should render(tag).as(expected)
      end
    end
  end

  describe "simple_spam_filter_required is false" do
    before do
      Radiant::Config['comments.simple_spam_filter_required?'] = false
    end

    describe "r:if_comments_use_simple_spam_filter" do
      it "should not render the content" do
        tag = %{<r:if_comments_use_simple_spam_filter>foo</r:if_comments_use_simple_spam_filter>}
        expected = ''
        pages(:home).should render(tag).as(expected)
      end
    end
    describe "r:unless_comments_use_simple_spam_filter" do
      it "should render the content" do
        tag = %{<r:unless_comments_use_simple_spam_filter>foo</r:unless_comments_use_simple_spam_filter>}
        expected = 'foo'
        pages(:home).should render(tag).as(expected)
      end
    end
  end

  describe "inverse captcha tags" do
    before do
      @key = 'xyzzy'
      Comment.stub!(:inverse_captcha_key).and_return(@key)
    end

    describe "r:inverse_captcha_tags" do
      it "should render a text input tag for the inverse captcha value" do
        tag = %{<r:inverse_captcha_tags/>}
        expected = %r{<input type="text" id="comment_author_ick_#{@key}" name="comment\[author_ick_#{@key}\]" class="required" />}
        pages(:home).should render(tag).matching(expected)
      end
      it "should render a hidden input tag for the hashed key value" do
        tag = %{<r:inverse_captcha_tags/>}
        expected = %r{<input type="hidden" id="comment_inverse_captcha_key" name="comment\[inverse_captcha_key\]" value="#{Digest::MD5.hexdigest(@key)}" />}
        pages(:home).should render(tag).matching(expected)
      end
      it "should render a hidden paragraph block containing the email input field and a warning message" do
        tag = %{<r:inverse_captcha_tags/>}
        expected = %r{<p style="display:\s*none;?">[^<]+<br />\s*<label for="comment_author_email">Please do not enter anything[^<]*</label><br />\s*<input type="text" id="comment_author_email" name="comment\[author_email\]" class="required" /></p>}
        pages(:home).should render(tag).matching(expected)
      end
    end
  end

  describe "inverse_captcha is true" do
    before do
      Radiant::Config['comments.inverse_captcha_required?'] = true
    end

    describe "r:if_comments_use_inverse_captcha" do
      it "should render the content" do
        tag = %{<r:if_comments_use_inverse_captcha>foo</r:if_comments_use_inverse_captcha>}
        expected = 'foo'
        pages(:home).should render(tag).as(expected)
      end
    end
    describe "r:unless_comments_use_inverse_captcha" do
      it "should not render the content" do
        tag = %{<r:unless_comments_use_inverse_captcha>foo</r:unless_comments_use_inverse_captcha>}
        expected = ''
        pages(:home).should render(tag).as(expected)
      end
    end
  end

  describe "inverse_captcha is false" do
    before do
      Radiant::Config['comments.inverse_captcha_required?'] = false
    end

    describe "r:if_comments_use_inverse_captcha" do
      it "should not render the content" do
        tag = %{<r:if_comments_use_inverse_captcha>foo</r:if_comments_use_inverse_captcha>}
        expected = ''
        pages(:home).should render(tag).as(expected)
      end
    end
    describe "r:unless_comments_use_inverse_captcha" do
      it "should render the content" do
        tag = %{<r:unless_comments_use_inverse_captcha>foo</r:unless_comments_use_inverse_captcha>}
        expected = 'foo'
        pages(:home).should render(tag).as(expected)
      end
    end
  end
  
end
