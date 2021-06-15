class UsersController < ApplicationController
    before_action :set_user, only: [:show]

    def spotify
      spotify_user = RSpotify::User.new(request.env['omniauth.auth'])
      stored_user = User.where(:email => spotify_user.email)
      if stored_user.empty?
        @user = User.create(:user_hash => spotify_user.to_hash, :email => spotify_user.email)
        redirect_to user_path(@user)
      else
        redirect_to user_path(stored_user.first)
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