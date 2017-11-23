class RelationshipsController < ApplicationController
  before_action :authenticate_user!

  def create
    @user = User.find(relationship_params[:followed_id])
    @button_size = relationship_params[:button_size]
    current_user.follow!(@user)
    respond_to do |format|
      format.html { redirect_back(fallback_location: user_path(@user)) }
      format.js
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    @button_size = relationship_params[:button_size]
    current_user.unfollow!(@user)
    respond_to do |format|
      format.html { redirect_back(fallback_location: user_path(@user)) }
      format.js
    end
  end

private

  def relationship_params
    params.require(:relationship).permit(:followed_id, :button_size)
  end
end
