# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_05_19_224703) do

  create_table "artist_room_relations", force: :cascade do |t|
    t.integer "artist_id", null: false
    t.integer "room_id", null: false
    t.integer "score"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["artist_id"], name: "index_artist_room_relations_on_artist_id"
    t.index ["room_id"], name: "index_artist_room_relations_on_room_id"
  end

  create_table "artists", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "playlist_artist_relations", force: :cascade do |t|
    t.integer "playlist_id", null: false
    t.integer "artist_id", null: false
    t.integer "rank"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["artist_id"], name: "index_playlist_artist_relations_on_artist_id"
    t.index ["playlist_id"], name: "index_playlist_artist_relations_on_playlist_id"
  end

  create_table "playlist_track_relations", force: :cascade do |t|
    t.integer "playlist_id", null: false
    t.integer "track_id", null: false
    t.integer "rank"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["playlist_id"], name: "index_playlist_track_relations_on_playlist_id"
    t.index ["track_id"], name: "index_playlist_track_relations_on_track_id"
  end

  create_table "playlists", force: :cascade do |t|
    t.integer "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_playlists_on_user_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.string "password"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "selected_playlists", force: :cascade do |t|
    t.integer "user_room_relation_id", null: false
    t.integer "playlist_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["playlist_id"], name: "index_selected_playlists_on_playlist_id"
    t.index ["user_room_relation_id"], name: "index_selected_playlists_on_user_room_relation_id"
  end

  create_table "track_room_relations", force: :cascade do |t|
    t.integer "track_id", null: false
    t.integer "room_id", null: false
    t.integer "score"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["room_id"], name: "index_track_room_relations_on_room_id"
    t.index ["track_id"], name: "index_track_room_relations_on_track_id"
  end

  create_table "tracks", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_room_relations", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "room_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["room_id"], name: "index_user_room_relations_on_room_id"
    t.index ["user_id"], name: "index_user_room_relations_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "artist_room_relations", "artists"
  add_foreign_key "artist_room_relations", "rooms"
  add_foreign_key "playlist_artist_relations", "artists"
  add_foreign_key "playlist_artist_relations", "playlists"
  add_foreign_key "playlist_track_relations", "playlists"
  add_foreign_key "playlist_track_relations", "tracks"
  add_foreign_key "playlists", "users"
  add_foreign_key "selected_playlists", "playlists"
  add_foreign_key "selected_playlists", "user_room_relations"
  add_foreign_key "track_room_relations", "rooms"
  add_foreign_key "track_room_relations", "tracks"
  add_foreign_key "user_room_relations", "rooms"
  add_foreign_key "user_room_relations", "users"
end
