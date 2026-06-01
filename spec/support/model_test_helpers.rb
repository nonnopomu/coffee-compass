# frozen_string_literal: true

require "securerandom"

module ModelTestHelpers
  def unique_suffix
    SecureRandom.hex(4)
  end

  def build_user(
    email: "user-#{unique_suffix}@example.com",
    name: "テストユーザー",
    password: "password",
    password_confirmation: password,
    role: :general
  )
    User.new(email:, name:, password:, password_confirmation:, role:)
  end

  def create_user(**attributes)
    build_user(**attributes).tap(&:save!)
  end

  def build_cafe(
    name: "テストカフェ #{unique_suffix}",
    address: "東京都渋谷区テスト1-1-1",
    prefecture: "東京都",
    google_maps_url: "https://maps.example.com/#{unique_suffix}",
    status: :draft,
    description: "落ち着いてコーヒーを楽しめるカフェ"
  )
    Cafe.new(name:, address:, prefecture:, google_maps_url:, status:, description:)
  end

  def create_cafe(**attributes)
    build_cafe(**attributes).tap(&:save!)
  end

  def create_tag(category:, name: "#{category}-#{unique_suffix}", display_order: 1, is_active: true)
    Tag.create!(category:, name:, display_order:, is_active:)
  end

  def create_roast_level_tag(**attributes)
    create_tag(category: :roast_level, name: "浅煎り #{unique_suffix}", **attributes)
  end

  def create_taste_tag(**attributes)
    create_tag(category: :taste, name: "フルーティー #{unique_suffix}", **attributes)
  end

  def create_brew_method_tag(**attributes)
    create_tag(category: :brew_method, name: "ハンドドリップ #{unique_suffix}", **attributes)
  end

  def create_cafe_feature_tag(**attributes)
    create_tag(category: :cafe_feature, name: "静か #{unique_suffix}", **attributes)
  end

  def build_drink_log(
    user: create_user,
    cafe: create_cafe,
    roast_level_tag: create_roast_level_tag,
    brew_method_tag: create_brew_method_tag,
    taste_tag: create_taste_tag,
    menu_name: "本日のコーヒー",
    drank_on: Date.current,
    memo: "香りがよかった",
    status: :published
  )
    drink_log = DrinkLog.new(
      user:,
      cafe:,
      roast_level_tag:,
      brew_method_tag:,
      menu_name:,
      drank_on:,
      memo:,
      status:
    )

    # DrinkLogは味わいタグが必須なので、保存前に中間レコードを組み立てる。
    drink_log.drink_log_taste_tags.build(tag: taste_tag) if taste_tag

    drink_log
  end

  def create_drink_log(**attributes)
    build_drink_log(**attributes).tap(&:save!)
  end
end
