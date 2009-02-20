module Admin
  class Articles < Application

    layout :admin

    before :ensure_authenticated
    # provides :xml, :yaml, :js

    def index
      @articles = Article.all(:order => [:published_at.desc])
      display @articles
    end

    def show(id)
      @article = Article.get(id)
      raise NotFound unless @article
      display @article
    end

    def new
      only_provides :html
      @article = Article.new :locale => 'en'
      display @article
    end

    def edit(id)
      only_provides :html
      @article = Article.get(id)
      raise NotFound unless @article
      display @article, :new
    end

    def create
      @article = Article.new_with_translation(params)
      if @article.save_with_translation(session.user)
        redirect url(:admin_article, @article), :message => {:notice => "Article was successfully created"}
      else
        message[:error] = "Article failed to be created"
        render :new
      end
    end

    def update
      @article = Article.get(params[:id])
      raise NotFound unless @article
      if @article.update_with_translation(params)
        redirect url(:admin_article, @article), :message => {:notice => "Article was successfully edited"}
      else
        display @article, :new
      end
    end

    def delete(id)
      only_provides :html
      @article = Article.get(id)
      render
    end

    def destroy(id)
      @article = Article.get(id)
      raise NotFound unless @article
      if @article.destroy
        redirect url(:admin_articles)
      else
        raise InternalServerError
      end
    end

  end # Articles
end # Admin
