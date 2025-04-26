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

ActiveRecord::Schema[8.0].define(version: 2025_04_26_125343) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "vector"

  create_table "api_sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "endpoint"
    t.jsonb "request_params"
    t.index ["request_params"], name: "index_api_sessions_on_request_params", using: :gin
    t.index ["user_id"], name: "index_api_sessions_on_user_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "company_markets", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.bigint "market_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "market_id"], name: "index_company_markets_on_company_id_and_market_id", unique: true
    t.index ["company_id"], name: "index_company_markets_on_company_id"
    t.index ["market_id"], name: "index_company_markets_on_market_id"
  end

  create_table "domains", force: :cascade do |t|
    t.string "name"
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "extracted_content", default: {}, null: false
    t.index ["company_id"], name: "index_domains_on_company_id"
    t.index ["extracted_content"], name: "index_domains_on_extracted_content", using: :gin
  end

  create_table "feature_extraction_queries", force: :cascade do |t|
    t.text "content"
    t.vector "embedding", limit: 1024
    t.string "search_field"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "keyword_markets", force: :cascade do |t|
    t.bigint "keyword_id", null: false
    t.bigint "market_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["keyword_id", "market_id"], name: "index_keyword_markets_on_keyword_id_and_market_id", unique: true
    t.index ["keyword_id"], name: "index_keyword_markets_on_keyword_id"
    t.index ["market_id"], name: "index_keyword_markets_on_market_id"
  end

  create_table "keyword_web_pages", force: :cascade do |t|
    t.bigint "keyword_id", null: false
    t.bigint "web_page_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["keyword_id", "web_page_id"], name: "index_keyword_web_pages_on_keyword_id_and_web_page_id", unique: true
    t.index ["keyword_id"], name: "index_keyword_web_pages_on_keyword_id"
    t.index ["web_page_id"], name: "index_keyword_web_pages_on_web_page_id"
  end

  create_table "keywords", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "market_providers", force: :cascade do |t|
    t.bigint "market_id", null: false
    t.bigint "provider_id", null: false
    t.string "market_name", null: false
    t.string "market_url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.integer "competitors_count"
    t.index ["market_id"], name: "index_market_providers_on_market_id"
    t.index ["provider_id", "market_id"], name: "index_market_providers_on_provider_id_and_market_id", unique: true
    t.index ["provider_id"], name: "index_market_providers_on_provider_id"
  end

  create_table "markets", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "posts", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "providers", force: :cascade do |t|
    t.string "name", null: false
    t.string "domain", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "recaptcha_challenges", force: :cascade do |t|
    t.text "img_base64"
    t.text "base64_images", default: [], array: true
    t.integer "tiles_nb"
    t.string "keyword"
    t.string "challenge"
    t.text "python_script"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "search_engine_results", force: :cascade do |t|
    t.string "site_name", null: false
    t.string "url", null: false
    t.string "title", null: false
    t.string "query", null: false
    t.text "description", null: false
    t.integer "position", null: false
    t.boolean "is_company"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "software_applications", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "domain_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider_url"
    t.text "description"
    t.string "provider_redirect_url"
    t.string "url"
    t.float "rating"
    t.integer "rating_count"
    t.index ["domain_id"], name: "index_software_applications_on_domain_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "user", null: false
    t.string "api_token"
    t.integer "api_credit", default: 0
    t.index ["api_token"], name: "index_users_on_api_token"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  create_table "web_page_chunks", force: :cascade do |t|
    t.bigint "web_page_id", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.vector "embedding", limit: 1024
    t.index ["web_page_id"], name: "index_web_page_chunks_on_web_page_id"
  end

  create_table "web_pages", force: :cascade do |t|
    t.string "url", null: false
    t.bigint "domain_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "content"
    t.text "summary"
    t.vector "summary_embedding", limit: 1024
    t.index ["domain_id"], name: "index_web_pages_on_domain_id"
  end

  add_foreign_key "api_sessions", "users"
  add_foreign_key "company_markets", "companies"
  add_foreign_key "company_markets", "markets"
  add_foreign_key "domains", "companies"
  add_foreign_key "keyword_markets", "keywords"
  add_foreign_key "keyword_markets", "markets"
  add_foreign_key "keyword_web_pages", "keywords"
  add_foreign_key "keyword_web_pages", "web_pages"
  add_foreign_key "market_providers", "markets"
  add_foreign_key "market_providers", "providers"
  add_foreign_key "sessions", "users"
  add_foreign_key "software_applications", "domains"
  add_foreign_key "web_page_chunks", "web_pages"
  add_foreign_key "web_pages", "domains"
end
