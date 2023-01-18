class ArticlesController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :authenticate_admin!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_news_letter
  before_action :set_article, only: [:show, :edit, :update, :destroy]

  # GET /articles/1
  # GET /articles/1.json
  def show
    @no_background = true
  end

  def new
    @article = @news_letter.articles.build
  end

  def create
    ActiveRecord::Base.transaction do
      @article = @news_letter.articles.build(article_params)

      respond_to do |format|
        if @article.save
          format.html { redirect_to @news_letter,
            notice: 'Article was successfully created.' }
          format.json { render :show, status: :created, location: @news_letter }
        else
          format.html { render :new }
          format.json { render json: @article.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @article.update(article_params)
        format.html {
          redirect_to @news_letter,
          notice: 'Article was successfully updated.'
        }
        format.json { render :show, status: :ok, location: @article }
      else
        format.html { render :edit }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @article.destroy
    respond_to do |format|
      format.html { redirect_to @news_letter, notice: 'Article was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_news_letter
    @news_letter = NewsLetter.find(params[:news_letter_id])
  end

  def set_article
    @article = @news_letter.articles.find(params[:id])
  end

  def article_params
    params.require(:article).permit(:title, :content, :image)
  end
end
