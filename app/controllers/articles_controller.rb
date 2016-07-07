class ArticlesController < ApplicationController

  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    permission_denied unless current_user.admin
    @article = Article.new
  end

  def edit
    permission_denied unless current_user.admin
    @article = Article.find(params[:id])
  end

  def create
    permission_denied unless current_user.admin
    @article = Article.new(article_params)
    if @article.save
      redirect_to @article
    else
      render 'new'
    end
  end

  def update
    permission_denied unless current_user.admin
    @article = Article.find(params[:id])
    if @article.update(article_params)
      redirect_to @article
    else
      render 'edit'
    end
  end

  def destroy
    permission_denied unless current_user.admin
    @article = Article.find(params[:id])
    @article.destroy
    redirect_to articles_path
  end

  private
    def article_params
      params.require(:article).permit(:title, :text)
    end
end
