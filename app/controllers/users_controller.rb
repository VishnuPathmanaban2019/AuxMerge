class UsersController < ApplicationController
    before_action :set_user, only: [:show]

    def spotify
      spotify_user = RSpotify::User.new(request.env['omniauth.auth'])
      # Now you can access user's private data, create playlists and much more
      User.create(:user_hash => spotify_user.to_hash)
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)
      redirect_to user_path(@user)
  
      if @user.save
        # if saved to database
        flash[:notice] = "Successfully accessed user information."
      else 
        flash[:notice] = "Could not access user information."
      end
    end
  
    def show 
      spotify_user = RSpotify::User.new(@user.user_hash)
      @display_name = spotify_user.display_name
    end

    private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:user_hash)
    end
  end