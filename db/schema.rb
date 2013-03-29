# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130329102332) do

  create_table "aggregate_bid_statistics", :force => true do |t|
    t.integer  "aggregate_statistic_type_id"
    t.integer  "duration"
    t.decimal  "average_bids",                :precision => 11, :scale => 2
    t.integer  "tender_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "aggregate_cpv_group_revenues", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "aggregate_cpv_revenues", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "cpv_code"
    t.decimal  "total_value",     :precision => 11, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "aggregate_cpv_statistics", :force => true do |t|
    t.integer  "aggregate_statistic_type_id"
    t.integer  "cpv_code"
    t.decimal  "value",                       :precision => 11, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "aggregate_statistic_types", :force => true do |t|
    t.integer  "aggregate_statistic_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "aggregate_statistics", :force => true do |t|
    t.integer  "year"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "aggregate_tender_statistics", :force => true do |t|
    t.integer  "aggregate_statistic_type_id"
    t.integer  "count"
    t.integer  "success_count"
    t.integer  "total_value"
    t.decimal  "average_bid_duration",        :precision => 11, :scale => 2
    t.decimal  "average_warning_period",      :precision => 11, :scale => 2
    t.integer  "total_bidders"
    t.integer  "total_bids"
    t.integer  "agreements"
    t.string   "illegal_tenders"
    t.string   "bidding_times_stats"
    t.string   "bidding_warning_stats"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "agreements", :force => true do |t|
    t.integer  "tender_id"
    t.integer  "organization_id"
    t.integer  "organization_url"
    t.decimal  "amount",            :precision => 11, :scale => 2
    t.date     "start_date"
    t.date     "expiry_date"
    t.string   "documentation_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "amendment_number"
    t.string   "currency"
  end

  add_index "agreements", ["tender_id", "organization_id"], :name => "index_agreements_on_tender_id_and_organization_id"

  create_table "bidders", :force => true do |t|
    t.integer  "tender_id"
    t.integer  "organization_url"
    t.integer  "organization_id"
    t.decimal  "first_bid_amount", :precision => 11, :scale => 2
    t.date     "first_bid_date"
    t.decimal  "last_bid_amount",  :precision => 11, :scale => 2
    t.date     "last_bid_date"
    t.integer  "number_of_bids"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bidders", ["tender_id", "organization_id"], :name => "index_bidders_on_tender_id_and_organization_id"

  create_table "competitors", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "rival_org_id"
    t.integer  "num_tenders"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "corruption_indicators", :force => true do |t|
    t.integer  "weight"
    t.string   "description"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cpv_groups", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "name"
    t.string   "type"
  end

  create_table "cpv_groups_tender_cpv_classifiers", :id => false, :force => true do |t|
    t.integer "cpv_group_id"
    t.integer "tender_cpv_classifier_id"
  end

  create_table "datasets", :force => true do |t|
    t.boolean  "is_live"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "documents", :force => true do |t|
    t.integer  "tender_id"
    t.string   "document_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.string   "author"
    t.datetime "date"
  end

  create_table "organizations", :force => true do |t|
    t.integer  "code",             :limit => 8
    t.string   "organization_url"
    t.string   "name"
    t.string   "country"
    t.string   "org_type"
    t.boolean  "is_bidder",                     :default => false
    t.boolean  "is_procurer",                   :default => false
    t.string   "city"
    t.string   "address"
    t.string   "phone_number"
    t.string   "fax_number"
    t.string   "email"
    t.string   "webpage"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "dataset_id"
    t.string   "translation"
  end

  add_index "organizations", ["organization_url", "name"], :name => "index_organizations_on_organization_url_and_name"

  create_table "searches", :force => true do |t|
    t.integer  "user_id"
    t.string   "search_string"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "searchtype"
    t.integer  "count"
    t.boolean  "email_alert"
    t.boolean  "has_updated"
    t.datetime "last_viewed"
  end

  create_table "tender_corruption_flags", :force => true do |t|
    t.integer  "tender_id"
    t.integer  "corruption_indicator_id"
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tender_cpv_classifiers", :force => true do |t|
    t.string   "cpv_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description"
    t.string   "description_english"
  end

  create_table "tender_cpv_codes", :force => true do |t|
    t.integer  "tender_id"
    t.integer  "cpv_code"
    t.string   "description"
    t.string   "english_description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tenders", :force => true do |t|
    t.integer  "procurring_entity_id"
    t.string   "tender_type"
    t.string   "tender_registration_number"
    t.string   "tender_status"
    t.date     "tender_announcement_date"
    t.date     "bid_start_date"
    t.date     "bid_end_date"
    t.decimal  "estimated_value",            :precision => 11, :scale => 2
    t.boolean  "include_vat",                                               :default => false
    t.string   "cpv_code"
    t.string   "addition_info"
    t.string   "units_to_supply"
    t.string   "supply_period"
    t.string   "offer_step"
    t.string   "guarantee_amount"
    t.string   "guarantee_period"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "dataset_id"
    t.integer  "url_id"
    t.integer  "num_bids"
    t.integer  "num_bidders"
  end

  add_index "tenders", ["estimated_value"], :name => "index_tenders_on_estimated_value"
  add_index "tenders", ["procurring_entity_id"], :name => "index_tenders_on_procurring_entity_id"
  add_index "tenders", ["tender_status"], :name => "index_tenders_on_tender_status"
  add_index "tenders", ["tender_type"], :name => "index_tenders_on_tender_type"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "role",                   :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "watch_tenders", :force => true do |t|
    t.integer  "user_id"
    t.string   "tender_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "hash"
    t.boolean  "email_alert"
    t.boolean  "has_updated"
  end

end
