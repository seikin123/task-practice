class PostsController < ApplicationController

  def index
    @posts = Post.all
end

def new
  @post = Post.new
end

def create
  @post = Post.new(post_params)
  @post.save
  redirect_to action: 'index'
end

# private以下は、一番下に記入します。
private
  def post_params
    params.require(:post).permit(:title, :body)
  end
end