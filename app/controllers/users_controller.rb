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

    def join_room
      if !(params[:form].nil?)
        room_id = params[:form][:room_id] if params[:form][:room_id]
        user_id = params[:id]
      end
      if !(room_id.nil?)
        begin
          room = Room.find(room_id)
          urr = UserRoomRelation.where(:user_id => user_id, :room_id => room_id)
          if urr.empty?
            redirect_to new_user_room_relation_path(user_id: user_id, room_id: room_id)
          else
            redirect_to room_path(room_id, :user_id => user_id)
          end
        rescue Exception => exc
             flash[:notice] = "Enter a valid room ID."
             redirect_to join_room_path
        end
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