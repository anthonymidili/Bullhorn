class RepostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_repost

  def create
    @post = current_user.posts.build
    @repost = @post.build_repost(user: current_user, reposted: @reposting)
    respond_to do |format|
      if @post.save
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.prepend(
              "posts", partial: "posts/post",
              locals: { post: @post }
            ),
            turbo_stream.replace_all(
              ".#{helpers.dom_id(@reposting, "repost_form")}",
              partial: "reposts/form", locals: { post: @reposting }
            ),
            turbo_stream.replace_all(
              ".#{helpers.dom_id(@reposting, "who_reposted")}",
              partial: "reposts/count", locals: { post: @reposting }
            )
          ]
        end
        format.html {
          redirect_back(fallback_location: root_path, notice: "Successfully reposted.")
        }
        format.json { render :show, status: :created, location: @post }
      else
        format.html {
          redirect_back(fallback_location: root_path, notice: "Repost already exists.")
        }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @post = current_user.reposts.find_by(reposted: @reposting).post
    @post.destroy
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(@post),
          turbo_stream.replace_all(
            ".#{helpers.dom_id(@reposting, "repost_form")}",
            partial: "reposts/form", locals: { post: @reposting }
          ),
          turbo_stream.replace_all(
            ".#{helpers.dom_id(@reposting, "who_reposted")}",
            partial: "reposts/count", locals: { post: @reposting }
          )
        ]
      end
      format.html {
        redirect_back(fallback_location: root_path, notice: "Successfully Unreposted.")
      }
    end
  end

  def who
  end

  def select
  end

private

  def repost_params
    params.require(:repost).permit(:post_id)
  end

  def set_repost
    @reposting = Post.find_by(id: repost_params[:post_id])
    redirect_to root_path unless @reposting
  end
end
