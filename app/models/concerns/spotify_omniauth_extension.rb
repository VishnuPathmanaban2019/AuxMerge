module SpotifyOmniauthExtension
    extend ActiveSupport::Concerns
  
    def callback_url
      full_host + script_name + callback_path
    end
end