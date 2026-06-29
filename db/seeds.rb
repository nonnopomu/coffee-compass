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
    "中浅煎り",
    "中煎り",
    "中深煎り",
    "深煎り"
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

Tag.roast_level.where.not(name: seed_tags[:roast_level]).find_each do |tag|
  tag.update!(is_active: false)
end

def rename_taste_parent_tag(old_name, new_name)
  old_tag = Tag.taste.find_by(name: old_name, parent_id: nil)
  return if old_tag.blank?

  new_tag = Tag.taste.find_by(name: new_name, parent_id: nil)

  if new_tag.present?
    old_tag.children.update_all(parent_id: new_tag.id)

    DrinkLogTasteTag.where(tag: old_tag).find_each do |drink_log_taste_tag|
      if DrinkLogTasteTag.exists?(drink_log_id: drink_log_taste_tag.drink_log_id, tag_id: new_tag.id)
        drink_log_taste_tag.destroy!
      else
        drink_log_taste_tag.update!(tag: new_tag)
      end
    end

    old_tag.update!(is_active: false, beginner_display_order: nil)
  else
    old_tag.update!(name: new_name)
  end
end

rename_taste_parent_tag("柑橘", "シトラス")
rename_taste_parent_tag("桃", "ストーンフルーツ")

flavor_tag_groups = [
  {
    name: "花",
    color_hex: "#F0CCC9",
    beginner_display_order: 1,
    children: [
      { name: "ジャスミン", color_hex: "#F7F1DD" },
      { name: "ローズ", color_hex: "#E8A7B4" },
      { name: "ラベンダー", color_hex: "#B79AD6" },
      { name: "カモミール", color_hex: "#F2D35E" }
    ]
  },
  {
    name: "ベリー",
    color_hex: "#D64550",
    beginner_display_order: 2,
    children: [
      { name: "ストロベリー", color_hex: "#D95B5B" },
      { name: "ラズベリー", color_hex: "#D95B5B" },
      { name: "ブルーベリー", color_hex: "#8E3A59" },
      { name: "カシス", color_hex: "#8E3A59" }
    ]
  },
  {
    name: "ブドウ・ワイン",
    color_hex: "#8E2F5C",
    beginner_display_order: 3,
    children: [
      { name: "ブドウ", color_hex: "#7B4A72" },
      { name: "赤ワイン", color_hex: "#7B4A72" },
      { name: "レーズン", color_hex: "#7B4A47" },
      { name: "プルーン", color_hex: "#7B4A47" }
    ]
  },
  {
    name: "シトラス",
    color_hex: "#E2D438",
    beginner_display_order: 4,
    children: [
      { name: "レモン", color_hex: "#F2D35E" },
      { name: "オレンジ", color_hex: "#E9994A" },
      { name: "グレープフルーツ", color_hex: "#F2D35E" },
      { name: "ライム", color_hex: "#B9D36A" }
    ]
  },
  {
    name: "リンゴ",
    color_hex: "#A6C83A",
    beginner_display_order: 5,
    children: [
      { name: "青リンゴ", color_hex: "#B9D36A" },
      { name: "赤リンゴ", color_hex: "#D98764" },
      { name: "洋梨", color_hex: "#D9C86A" },
      { name: "シードル", color_hex: "#A9C8A4" }
    ]
  },
  {
    name: "ストーンフルーツ",
    color_hex: "#F08A70",
    beginner_display_order: 6,
    children: [
      { name: "桃", color_hex: "#E8A07A" },
      { name: "白桃", color_hex: "#F3D6C8" },
      { name: "アプリコット", color_hex: "#E7A950" },
      { name: "チェリー", color_hex: "#D86458" }
    ]
  },
  {
    name: "トロピカルフルーツ",
    color_hex: "#EFB83E",
    beginner_display_order: 7,
    children: [
      { name: "パイナップル", color_hex: "#E7A950" },
      { name: "マンゴー", color_hex: "#E7A950" },
      { name: "パッションフルーツ", color_hex: "#E7A950" },
      { name: "グァバ", color_hex: "#E8A07A" }
    ]
  },
  {
    name: "はちみつ",
    color_hex: "#D99A2B",
    beginner_display_order: 8,
    children: [
      { name: "はちみつ", color_hex: "#D9A441" },
      { name: "花蜜", color_hex: "#F2D35E" },
      { name: "アカシアハニー", color_hex: "#F7F1DD" },
      { name: "バニラ", color_hex: "#F7F1DD" }
    ]
  },
  {
    name: "黒糖・キャラメル",
    color_hex: "#A8652D",
    beginner_display_order: 9,
    children: [
      { name: "黒糖", color_hex: "#8B5E34" },
      { name: "ブラウンシュガー", color_hex: "#8B5E34" },
      { name: "メープル", color_hex: "#B98547" },
      { name: "キャラメル", color_hex: "#B86B3E" }
    ]
  },
  {
    name: "ナッツ",
    color_hex: "#8A5A3B",
    beginner_display_order: 10,
    children: [
      { name: "アーモンド", color_hex: "#9B6A3C" },
      { name: "ヘーゼルナッツ", color_hex: "#9B6A3C" },
      { name: "ピーナッツ", color_hex: "#9B6A3C" },
      { name: "クルミ", color_hex: "#8B5E34" }
    ]
  },
  {
    name: "チョコレート",
    color_hex: "#5B392A",
    beginner_display_order: 11,
    children: [
      { name: "ココア", color_hex: "#8B5E34" },
      { name: "ミルクチョコレート", color_hex: "#8B5E34" },
      { name: "ダークチョコレート", color_hex: "#4A2F25" },
      { name: "カカオニブ", color_hex: "#4A2F25" }
    ]
  },
  {
    name: "トースト",
    color_hex: "#C98A3A",
    beginner_display_order: 12,
    children: [
      { name: "トースト", color_hex: "#B98547" },
      { name: "ビスケット", color_hex: "#E7A950" },
      { name: "モルト・麦芽", color_hex: "#E7A950" },
      { name: "スモーキー", color_hex: "#4A403A" }
    ]
  }
]

active_taste_tag_ids = []
taste_display_order = 1

flavor_tag_groups.each do |group|
  parent_tag = Tag.taste.where(parent_id: nil).find_or_initialize_by(name: group.fetch(:name))
  parent_tag.assign_attributes(
    display_order: taste_display_order,
    is_active: true,
    parent: nil,
    color_hex: group.fetch(:color_hex),
    beginner_display_order: group[:beginner_display_order]
  )
  parent_tag.save!
  active_taste_tag_ids << parent_tag.id
  taste_display_order += 1

  group.fetch(:children).each do |child|
    child_attributes = child.is_a?(Hash) ? child : { name: child }
    child_tag = Tag.taste.where(parent: parent_tag).find_or_initialize_by(name: child_attributes.fetch(:name))
    child_tag.assign_attributes(
      display_order: taste_display_order,
      is_active: true,
      parent: parent_tag,
      color_hex: child_attributes[:color_hex] || group.fetch(:color_hex),
      beginner_display_order: child_attributes[:beginner_display_order]
    )
    child_tag.save!
    active_taste_tag_ids << child_tag.id
    taste_display_order += 1
  end
end

Tag.taste.where.not(id: active_taste_tag_ids).find_each do |tag|
  tag.update!(is_active: false, beginner_display_order: nil)
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
