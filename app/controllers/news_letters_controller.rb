class NewsLettersController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :authenticate_admin!, only: [:new, :create, :edit, :update, :destroy, :publish, :un_publish]
  before_action :set_news_letter, only: [:show, :edit, :update, :destroy, :publish, :un_publish]
  before_action :set_no_background, only: [:index, :show]

  # GET /news_letters
  # GET /news_letters.json
  def index
    if user_signed_in? && current_user.is_admin
      @news_letters = NewsLetter.page(params[:page]).includes(:articles)
    else
      @news_letters = NewsLetter.by_published.page(params[:page]).includes(:articles)
    end
  end

  # GET /news_letters/1
  # GET /news_letters/1.json
  def show
    @future_events = Event.in_the_future.with_attached_image.
    includes([:address, user: [avatar_attachment: :blob]])
    @job_listings = JobListing.by_currently_listed.
    includes(company: [:address, logo_attachment: :blob])
  end

  # GET /news_letters/1/edit
  def edit
  end

  # POST /news_letters
  # POST /news_letters.json
  def create
    @news_letter = NewsLetter.create

    respond_to do |format|
      if @news_letter.save
        format.html { redirect_to @news_letter, notice: 'Newsletter was successfully created.' }
        format.json { render :show, status: :created, location: @news_letter }
      else
        format.html { render :new }
        format.json { render json: @news_letter.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /news_letters/1
  # PATCH/PUT /news_letters/1.json
  def update
    respond_to do |format|
      if @news_letter.update(news_letter_params)
        format.html { redirect_to @news_letter, notice: 'Newsletter was successfully updated.' }
        format.json { render :show, status: :ok, location: @news_letter }
      else
        format.html { render :edit }
        format.json { render json: @news_letter.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /news_letters/1
  # DELETE /news_letters/1.json
  def destroy
    @news_letter.destroy
    respond_to do |format|
      format.html { redirect_to news_letters_url, notice: 'Newsletter was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def publish
    @news_letter.published = true
    respond_to do |format|
      if @news_letter.save
        @news_letter.mail_recipients
        format.html {
          redirect_to @news_letter,
          notice: 'Newsletter was successfully published and an
          email was sent to notify the skypatrollers.'
        }
        format.js
      end
    end
  end

  def un_publish
    @news_letter.published = false
    respond_to do |format|
      if @news_letter.save
        format.html { redirect_to @news_letter, notice: 'Newsletter was successfully un-published.' }
        format.js
      end
    end
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_news_letter
    @news_letter = NewsLetter.includes(articles: [image_attachment: :blob]).find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def news_letter_params
    params.require(:news_letter).permit(:issue_number, :issued_on)
  end

  def set_no_background
    @no_background = true
  end
end
