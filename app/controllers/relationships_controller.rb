class RelationshipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_button_size

  def create
    @user = User.find(relationship_params[:followed_id])
    current_user.follow!(@user)
    respond_to do |format|
      format.html { redirect_back(fallback_location: user_path(@user)) }
      format.js
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow!(@user)
    respond_to do |format|
      format.html { redirect_back(fallback_location: user_path(@user)) }
      format.js
    end
  end

private

  def relationship_params
    params.require(:relationship).permit(:followed_id, :button_size, :profile_user_id)
  end

  def set_button_size
    @button_size = relationship_params[:button_size]
  end
end
