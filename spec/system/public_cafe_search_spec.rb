# frozen_string_literal: true

require "rails_helper"

RSpec.describe "公開カフェ検索", type: :system do
  it "未ログインユーザーがトップページから東京都のカフェを探し、詳細を閲覧できること" do
    tokyo_cafe = create_cafe(
      name: "東京テストカフェ",
      address: "東京都渋谷区神南1-1-1",
      prefecture: "東京都",
      google_maps_url: "https://maps.example.com/tokyo-test-cafe",
      status: :published,
      description: "System Specで公開導線を確認するカフェです"
    )
    hokkaido_cafe = create_cafe(
      name: "北海道テストカフェ",
      address: "北海道札幌市中央区北1条西1-1",
      prefecture: "北海道",
      google_maps_url: "https://maps.example.com/hokkaido-test-cafe",
      status: :published
    )

    visit root_path

    expect(page).to have_selector("h1", text: "Coffee Compass")

    click_button "エリアから探す"
    expect(page).to have_text("エリアを選択")

    check "東京都"
    click_button "このエリアで検索"

    expect(page).to have_current_path(cafes_path, ignore_query: true)
    expect(page).to have_selector("h1", text: "カフェ一覧")
    expect(page).to have_text(tokyo_cafe.name)
    expect(page).not_to have_text(hokkaido_cafe.name)

    click_link "詳細を見る"

    expect(page).to have_current_path(cafe_path(tokyo_cafe))
    expect(page).to have_selector("h1", text: tokyo_cafe.name)
    expect(page).to have_text(tokyo_cafe.address)
  end
end
