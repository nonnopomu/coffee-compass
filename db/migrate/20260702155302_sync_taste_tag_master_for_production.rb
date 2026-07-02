class SyncTasteTagMasterForProduction < ActiveRecord::Migration[8.1]
  def up
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

    Tag.transaction do
      Tag.taste.update_all(is_active: false, beginner_display_order: nil)

      rename_taste_parent_tag("柑橘", "シトラス")
      rename_taste_parent_tag("桃", "ストーンフルーツ")

      active_taste_tag_ids = []
      taste_display_order = 1

      flavor_tag_groups.each do |group|
        parent_tag = Tag.taste.where(parent_id: nil).find_or_initialize_by(name: group.fetch(:name))
        parent_tag.assign_attributes(
          display_order: taste_display_order,
          is_active: true,
          parent: nil,
          color_hex: group.fetch(:color_hex),
          beginner_display_order: group.fetch(:beginner_display_order)
        )
        parent_tag.save!

        active_taste_tag_ids << parent_tag.id
        taste_display_order += 1

        group.fetch(:children).each do |child|
          child_tag = Tag.taste.where(parent: parent_tag).find_or_initialize_by(name: child.fetch(:name))
          child_tag.assign_attributes(
            display_order: taste_display_order,
            is_active: true,
            parent: parent_tag,
            color_hex: child.fetch(:color_hex),
            beginner_display_order: nil
          )
          child_tag.save!

          active_taste_tag_ids << child_tag.id
          taste_display_order += 1
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

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
end
