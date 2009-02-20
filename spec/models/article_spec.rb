require File.join( File.dirname(__FILE__), '..', "spec_helper" )

require 'ruby-debug'

describe Article do

  before(:each) do
    Article.all.destroy!
    @article = Article.gen
  end

  it 'should be valid' do
    @article.should be_valid
  end

  it 'should be valid without author when built in memory' do
    @article.author = nil
    @article.should be_valid
  end

  it 'should not be valid for saving context without author' do
    @article.author = nil
    @article.should_not be_valid_for_saving
  end

  it 'should have an associated author to be saved' do
    @article.author = nil
    @article.save
    @article.errors.on(:author).should_not be_empty
  end

  describe "when published" do
    before(:each) do
      @article.published = true
    end

    it 'should have a body' do
      @article.body = nil
      @article.should_not be_valid
      @article.errors[:body].should_not be_empty
      @article.body = "Body of the article"
      @article.should be_valid
    end

    it 'should have a permalink' do
      @article.save
      @article.permalink.should_not be_blank
    end

    it 'should have a published date' do
      @article.save
      @article.published_at.should_not be_nil
    end
  end

  describe 'new_with_translation method' do

    describe 'without translation' do

      it 'should not build translation object' do
        params = { :article => {
            :title => "with no translation title",
            :body => "with no translation body",
            :locale => "en" },
          :have_translation => "0",
          :translation => {
            :title => "no translation title",
            :body => "no translation body",
            :id => ""}
        }

        non_translated = Article.new_with_translation params
        non_translated.translation.should be_nil
      end

    end

    describe 'with translation' do
      before(:all) do
        params = { :article => {
            :title => "article title",
            :body => "article body",
            :locale => "en" },
          :have_translation => "1",
          :translation => {
            :title => "translation title",
            :body => "translation body",
            :id => ""}
        }

        @translated = Article.new_with_translation params
      end

      it 'should initialize both valid article and translation' do
        @translated.should be_valid
        @translated.translation.should be_valid
      end

      it 'should assign article and translation locales correctly' do
        @translated.locale.should_not == @translated.translation.locale
      end

      it 'should assign article tags to translation tags' do
        @translated.tags.should == @translated.translation.tags
      end
    end

  end

  describe 'save_with_translation method' do
    before(:all) do
      @author = User.gen
    end

    describe 'when article is not valid' do
      before(:all) do
        fail_article_params = {
          :article => {
            :title => "",
            :body => "no title article body",
            :locale => "en" },
          :have_translation => "1",
          :translation => {
            :title => "no title article translation title",
            :body => "no title article translation body",
          }
        }

        @fail_article = Article.new_with_translation fail_article_params
      end

      # guaranteeing the article is really not valid
      it 'should no be valid' do
        @fail_article.should_not be_valid
      end

      it 'should return false' do
        @fail_article.save_with_translation(@author).should be_false
      end

      it 'should not create translation' do
        @fail_article.translation.should be_new_record
      end
    end

    describe 'when translation is not valid' do
      before(:all) do
        fail_translation_params = { :article => {
            :title => "with bad translation title",
            :body => "with bad translation body",
            :locale => "en" },
          :have_translation => "1",
          :translation => {
            :title => "",
            :body => "bad translation body",
            :id => ""}
        }

        @fail_translation = Article.new_with_translation fail_translation_params
      end

      # guaranteeing the article's translation is really not valid
      it 'translation should no be valid' do
        @fail_translation.translation.should_not be_valid
      end

      it 'should return false' do
        @fail_translation.save_with_translation(@author).should be_false
      end

      it 'should create article' do
        @fail_translation.should_not be_new_record
      end
    end

    describe 'when article and translation are both valid' do
      before(:all) do
        params = { :article => {
            :title => "good article",
            :body => "good article body",
            :tag_list => "tag1, tag2",
            :locale => "en" },
          :have_translation => "1",
          :translation => {
            :title => "good translation title",
            :body => "good translation body",
            :id => ""}
        }
        Article.all.destroy!
        @translated = Article.new_with_translation params
      end

      # guaranteeing the article is really valid
      it 'article should be valid' do
        @translated.should be_valid
      end

      # guaranteeing the article's translation is really valid
      it 'translation should no be valid' do
        @translated.translation.should be_valid
      end

      it 'should return true' do
        @translated.save_with_translation(@author).should be_true
      end

      #wtf con la desc
      it 'should create the translation' do
        @translated.translation.should_not be_nil
      end

      it 'should have both same author' do
        @translated.author.should == @translated.translation.author
      end

      it 'should make them point each other through translation' do
        translation = @translated.translation
        #FIXME why datamapper does not load the circular reference????
        @translated.id.should == translation.article_id
      end

      it 'tags should be the same for both' do
        @translated.tags.should == @translated.translation.tags
      end
    end

  end

#   describe 'have_translation? method' do
#     it 'should return false to non translated articles'#  do
#     #     it 'should create an article with translation' do
#     #       @translated.have_translation?.should be_true
#     #     end


#     #     end

#     it 'should return true to non translated articles'#  do

#     #     end
#   end

end
