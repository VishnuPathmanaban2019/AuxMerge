class UsersController < ApplicationController
    before_action :set_user, only: [:show, :join_room]

    def spotify
      spotify_user = RSpotify::User.new(request.env['omniauth.auth'])
      email = spotify_user.email
      stored_user = User.where(:email => email)
      if stored_user.empty?
        @user = User.create(:user_hash => spotify_user.to_hash, :email => email, :name => spotify_user.display_name)
        session[:current_user_id] = @user.id
        redirect_to user_path(@user)
      else
        session[:current_user_id] = stored_user.first.id
        redirect_to user_path(stored_user.first)
      end
    end

    def logout
      @_current_user = session[:current_user_id] = nil
      redirect_to home_path
    end

    def join_room
      if !(params[:id].nil?) and session[:current_user_id] == params[:id].to_i
        if !(params[:form].nil?)
          room_id = params[:form][:room_id] if params[:form][:room_id]
          password = params[:form][:password] if params[:form][:password]
          user_id = params[:id]
        end
        if !(room_id.nil?) and !(password.nil?)
          begin
            room = Room.find(room_id)
            if password != room.password
              flash[:notice] = "Incorrect password."
            else
              urr = UserRoomRelation.where(:user_id => user_id, :room_id => room_id)
              if urr.empty?
                @user.update_attribute(:valid_rooms, @user.valid_rooms.append(room_id.to_i))
                redirect_to new_user_room_relation_path(user_id: user_id, room_id: room_id)
              else
                redirect_to room_path(room_id, :user_id => user_id)
              end
            end
          rescue Exception => exc
              flash[:notice] = "Enter a valid room ID."
          end
        end
      else 
        flash[:notice] = "You do not have access to this section."
        redirect_to home_path
      end
    end
  
    def show 
      if session[:current_user_id] == @user.id
        
      else 
        flash[:notice] = "You do not have access to this section."
        redirect_to home_path
      end
    end

    private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:user_hash)
    end
  end