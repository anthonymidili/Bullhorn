class HashtagsController < ApplicationController
  before_action :authenticate_user!
  include InfiniteScroll

  def show
    @hashtag = Hashtag.find_by("name ILIKE ?", params[:name])
    @posts = @scrolled_objects || []
  end

  def search
    term = params[:term].to_s.sub(/\A#/, "").strip
    hashtags = if term.present?
      Hashtag.search(term).limit(8)
    else
      Hashtag.joins(:taggings).group(:id).order("COUNT(taggings.id) DESC").limit(8).presence || Hashtag.order(created_at: :desc).limit(8)
    end

    data = hashtags.map do |h|
      {
        key: h.name,
        value: h.name,
        name: "##{h.name}",
        count: h.taggings.count
      }
    end

    render json: data
  end
end
