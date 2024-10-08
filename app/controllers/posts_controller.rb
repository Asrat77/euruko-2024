class PostsController < ApplicationController
  # ----- unauthenticated actions -----
  allow_unauthenticated_access only: %i[ index show ]

  # GET /posts
  def index
    @posts = Post.all.order(created_at: :desc).limit(50)
  end

  # GET /posts/1
  def show
    @post = Post.find(params[:id])
  end

  # ----- authenticated actions -----
  before_action :set_and_authorize_post, only: %i[ edit update destroy ]

  # GET /posts/new
  def new
    post_attributes = if params[:lorem]
      {
        title: Faker::Lorem.words(number: rand(2..5)).join(" "),
        content: rand(5..10).times.collect { rand(5..10).times.collect { Faker::Lorem.sentence(word_count: rand(5..10)) }.join(" ") }.join("\n\n")
      }
    else
      {}
    end
    @post = Current.user.posts.new(post_attributes)
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  def create
    @post = Current.user.posts.new(post_params)

    if @post.save
      redirect_to @post, notice: "Post was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /posts/1
  def update
    if @post.update(post_params)
      redirect_to @post, notice: "Post was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /posts/1
  def destroy
    @post.destroy!
    redirect_to posts_url, notice: "Post was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_and_authorize_post
      @post = Post.find(params[:id])
      raise ApplicationController::NotAuthorized, "not allowed to #{action_name} this post" unless @post.user == Current.user
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:title, :content)
    end
end
