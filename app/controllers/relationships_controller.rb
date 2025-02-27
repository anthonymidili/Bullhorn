class RelationshipsController < ApplicationController
  before_action :authenticate_user!

  def create
    @relationship = current_user.relationships.build(relationship_params)
    @user = @relationship.followed

    respond_to do |format|
      if @relationship.save
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("follow_form_user_#{@user.id}",
              partial: "relationships/unfollow", locals: { user: @user }
            ),
            turbo_stream.update("followers_count_#{@user.id}", html: @user.followers.count),
            turbo_stream.update("following_count_#{current_user.id}", html: current_user.following.count)
          ]
        end
        format.html { redirect_to @relationship.followed, notice: "Relationship was successfully created." }
        format.json { render :show, status: :created, location: @relationship.followed }
      else
        format.html { render :new }
        format.json { render json: @relationship.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @relationship = current_user.relationships.find(params[:id])
    @user = @relationship.followed
    @relationship.destroy

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("unfollow_form_user_#{@user.id}",
            partial: "relationships/follow", locals: { user: @user }
          ),
          turbo_stream.update("followers_count_#{@user.id}", html: @user.followers.count),
          turbo_stream.update("following_count_#{current_user.id}", html: current_user.following.count)
        ]
      end
      format.html { redirect_to @user, notice: "Relationship was successfully destroyed." }
      format.json { head :no_content }
    end
  end

private

  def relationship_params
    params.require(:relationship).permit(:followed_id)
  end
end
