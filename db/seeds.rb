# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require "uri"

seed_tags = {
  roast_level: [
    "浅煎り",
    "中煎り",
    "深煎り"
  ],
  taste: [
    "フルーティー",
    "華やか",
    "すっきり",
    "酸味",
    "甘み",
    "コク",
    "ビター",
    "ナッツ",
    "チョコレート",
    "スパイス"
  ],
  brew_method: [
    "ハンドドリップ",
    "エスプレッソ",
    "ラテ",
    "デカフェ"
  ],
  cafe_feature: [
    "スペシャルティコーヒー",
    "浅煎り中心",
    "シングルオリジン",
    "自家焙煎",
    "豆販売",
    "テイクアウトOK",
    "作業しやすい",
    "静か",
    "カウンター席あり",
    "駅近"
  ]
}

seed_tags.each do |category, names|
  names.each.with_index(1) do |name, display_order|
    tag = Tag.find_or_initialize_by(category:, name:)
    tag.display_order = display_order
    tag.is_active = true
    tag.save!
  end
end

def google_maps_search_url(name, address)
  query = URI.encode_www_form_component("#{name} #{address}")
  "https://www.google.com/maps/search/?api=1&query=#{query}"
end

seed_cafes = [
  {
    name: "TRUNK COFFEE 高岳本店",
    prefecture: "愛知県",
    address: "愛知県名古屋市東区泉2-28-24 東和高岳ビル 1F",
    website_url: "https://www.trunkcoffee.com/",
    description: "名古屋・高岳のスペシャルティコーヒーロースター。コーヒー豆の個性を楽しみたい人に向いたカフェです。",
    status: :published,
    feature_tags: [ "スペシャルティコーヒー", "自家焙煎", "豆販売", "駅近" ]
  },
  {
    name: "Q.O.L.COFFEE",
    prefecture: "愛知県",
    address: "愛知県名古屋市中区丸の内3丁目5-1 マジマビル",
    website_url: "http://qolcoffee.com/",
    description: "名古屋・丸の内にあるスペシャルティコーヒーロースターカフェ。街歩きの途中にも立ち寄りやすい店舗です。",
    status: :published,
    feature_tags: [ "スペシャルティコーヒー", "自家焙煎", "駅近" ]
  },
  {
    name: "IMOM COFFEE",
    prefecture: "愛知県",
    address: "愛知県名古屋市中区錦1丁目2-34 CIRCLES錦 1F",
    website_url: "https://imom.co.jp/service/coffee.html",
    description: "国際センターエリアでスペシャルティコーヒーを楽しめるIMOMの店舗。自社焙煎のコーヒーを提供しています。",
    status: :published,
    feature_tags: [ "スペシャルティコーヒー", "自家焙煎", "豆販売" ]
  },
  {
    name: "GLITCH COFFEE NAGOYA",
    prefecture: "愛知県",
    address: "愛知県名古屋市中村区名駅2-42-2",
    website_url: "https://glitchcoffee.com/",
    description: "東京・神保町発のGLITCH COFFEEによる名古屋店。浅煎りのシングルオリジンを楽しめる店舗です。",
    status: :published,
    feature_tags: [ "スペシャルティコーヒー", "浅煎り中心", "シングルオリジン", "豆販売", "駅近" ]
  },
  {
    name: "SHRUB COFFEE NAGOYA",
    prefecture: "愛知県",
    address: "愛知県名古屋市中村区名駅南1-2-12",
    website_url: "https://shrubcoffee.com/",
    description: "名駅南・納屋橋エリアにあるSHRUB COFFEEの名古屋店。コーヒースタンドとして気軽に利用できます。",
    status: :published,
    feature_tags: [ "スペシャルティコーヒー", "豆販売", "テイクアウトOK" ]
  },
  {
    name: "GLITCH COFFEE & ROASTERS",
    prefecture: "東京都",
    address: "東京都千代田区神田錦町3-16 香村ビル 1F",
    website_url: "https://glitchcoffee.com/",
    description: "神保町にあるGLITCH COFFEEの店舗。浅煎りのシングルオリジンを中心に、豆の個性を楽しめます。",
    status: :published,
    feature_tags: [ "スペシャルティコーヒー", "浅煎り中心", "シングルオリジン", "豆販売" ]
  },
  {
    name: "LIGHT UP COFFEE 下北沢",
    prefecture: "東京都",
    address: "東京都世田谷区代田2-29-12",
    website_url: "https://lightupcoffee.com/pages/store",
    description: "下北沢と世田谷代田の間にあるLIGHT UP COFFEEの店舗。シングルオリジンのコーヒーを楽しめます。",
    status: :published,
    feature_tags: [ "スペシャルティコーヒー", "シングルオリジン", "豆販売" ]
  },
  {
    name: "KOFFEE MAMEYA",
    prefecture: "東京都",
    address: "東京都渋谷区神宮前4-15-3",
    website_url: "https://www.koffee-mameya.com/",
    description: "表参道にあるコーヒー豆専門店。バリスタに相談しながら豆を選べる、コーヒー好き向けの店舗です。",
    status: :published,
    feature_tags: [ "スペシャルティコーヒー", "豆販売", "駅近" ]
  },
  {
    name: "FUGLEN TOKYO",
    prefecture: "東京都",
    address: "東京都渋谷区富ヶ谷1-16-11",
    website_url: "https://fuglencoffee.jp/",
    description: "奥渋エリアにあるノルウェー発のカフェ。コーヒーと落ち着いた空間を楽しめる店舗です。",
    status: :published,
    feature_tags: [ "スペシャルティコーヒー", "豆販売" ]
  },
  {
    name: "ACID COFFEE TOKYO",
    prefecture: "東京都",
    address: "東京都渋谷区上原1-29-5 ビット代々木上原 1F",
    website_url: "https://acidcoffee.stores.jp/",
    description: "渋谷区上原にあるコーヒーショップ。フルーティーなコーヒーを楽しみたい人に向いた店舗です。",
    status: :published,
    feature_tags: [ "スペシャルティコーヒー", "浅煎り中心" ]
  }
]

seed_cafes.each do |cafe_attributes|
  feature_tag_names = cafe_attributes.fetch(:feature_tags)
  attributes = cafe_attributes.except(:feature_tags)
  attributes[:google_maps_url] = google_maps_search_url(attributes[:name], attributes[:address])

  cafe = Cafe.find_or_initialize_by(name: attributes[:name], address: attributes[:address])
  cafe.assign_attributes(attributes)
  cafe.save!

  feature_tag_names.each do |tag_name|
    tag = Tag.find_by!(category: :cafe_feature, name: tag_name)
    CafeTag.find_or_create_by!(cafe:, tag:)
  end
end

admin_email = ENV["ADMIN_EMAIL"]
admin_password = ENV["ADMIN_PASSWORD"]

if admin_email.present? && admin_password.present?
  admin = User.find_or_initialize_by(email: admin_email)
  admin.name = ENV.fetch("ADMIN_NAME", "管理者")
  admin.password = admin_password
  admin.password_confirmation = admin_password
  admin.role = :admin
  admin.save!
elsif Rails.env.production?
  raise "ADMIN_EMAILとADMIN_PASSWORDを設定してください"
end

review_admin_email = ENV["REVIEW_ADMIN_EMAIL"]
review_admin_password = ENV["REVIEW_ADMIN_PASSWORD"]

if review_admin_email.present? && review_admin_password.present?
  review_admin = User.find_or_initialize_by(email: review_admin_email)
  review_admin.name = ENV.fetch("REVIEW_ADMIN_NAME", "レビュー用管理者")
  review_admin.password = review_admin_password
  review_admin.password_confirmation = review_admin_password
  review_admin.role = :admin
  review_admin.save!
end
