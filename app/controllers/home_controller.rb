class HomeController < ApplicationController
    def index
    end 
    def result
        @creator_id = params[:creator_id] if params[:creator_id]
        @track_ids = params[:result] if params[:result]
        playlist = RSpotify::User.new(User.find(@creator_id).user_hash).create_playlist!('Group Playlist')
        @tracks = []
        @track_ids.each do |track_id|
            @tracks.append(RSpotify::Track.find(track_id))
        end
        playlist.add_tracks!(@tracks)
    end 
end