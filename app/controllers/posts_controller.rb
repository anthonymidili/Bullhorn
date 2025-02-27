class PostsController < ApplicationController
  before_action :authenticate_user!
  include InfiniteScroll
  before_action :set_post, only: [ :show, :edit, :update, :destroy ]
  before_action :deny_access!, only: [ :edit, :update, :destroy ],
  unless:  -> { correct_user?(@post.user) }
  before_action :set_repost, only: [ :new, :create ]
  before_action :set_as_read!, only: [ :show ]

  # GET /posts/1
  # GET /posts/1.json
  def show
    # @post set in InfiniteScroll.rb.
    @comment = @post.comments.build
    @hidden = true
  end

  # GET /posts/new
  def new
    @post = current_user.posts.build
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = current_user.posts.build(post_params)
    @repost = @post.build_repost(user: current_user, reposted: @reposting) if @reposting

    respond_to do |format|
      if @post.save
        format.turbo_stream
        format.html {
          redirect_to root_path(anchor: "post_#{@post.id}"),
          notice: "Post was successfully created."
        }
        format.json { render :show, status: :created, location: @post }
      else
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(helpers.dom_id(@post, "form"), partial: "posts/form",
            locals: { post: @post })
          ]
        end
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(@post, partial: "posts/post",
            locals: { post: @post })
          ]
        end
        format.html {
          redirect_to root_path(anchor: "post_#{@post.id}"),
          notice: "Post was successfully updated."
        }
        format.json { render :show, status: :ok, location: @post }
      else
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(helpers.dom_id(@post, "form"), partial: "posts/form",
            locals: { post: @post })
          ]
        end
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    @from_show = params[:from_show]

    respond_to do |format|
      format.turbo_stream
      format.html {
        redirect_to root_path,
        notice: "Post was successfully destroyed."
      }
      format.json { head :no_content }
    end
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_post
    @post = Post.includes(comments: :created_by).find_by(id: params[:id])
    redirect_to root_path unless @post
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def post_params
    params.require(:post).permit(:body)
  end

  def set_repost
    @reposting = Post.find_by(id: repost_params[:post_id]) if params[:repost]
  end

  def repost_params
    params.require(:repost).permit(:post_id)
  end
end
