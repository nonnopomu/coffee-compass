require "rails_helper"

RSpec.describe "Cafe search suggestions", type: :request do
  describe "GET /cafes/search_suggestions" do
    it "カフェ名検索の入力が空の場合は空の候補を返すこと" do
      get search_suggestions_cafes_path

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq({ "suggestions" => [] })

      get search_suggestions_cafes_path, params: { keyword: "  " }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq({ "suggestions" => [] })
    end

    it "カフェ名に一致する公開カフェを候補として返すこと" do
      matched_cafe = create_cafe(name: "札幌ロースター", status: :published)
      address_matched_cafe = create_cafe(name: "住所一致カフェ", address: "北海道札幌市中央区", status: :published)
      description_matched_cafe = create_cafe(name: "紹介文一致カフェ", description: "札幌で人気のお店", status: :published)

      get search_suggestions_cafes_path, params: { keyword: "札幌" }

      suggestions = JSON.parse(response.body).fetch("suggestions")

      expect(response).to have_http_status(:ok)
      expect(suggestions).to include(
        {
          "type" => "cafe",
          "label" => matched_cafe.name,
          "keyword" => matched_cafe.name
        }
      )
      expect(suggestions.map { |suggestion| suggestion.fetch("label") }).not_to include(address_matched_cafe.name)
      expect(suggestions.map { |suggestion| suggestion.fetch("label") }).not_to include(description_matched_cafe.name)
    end

    it "下書きや閉店のカフェは候補に返さないこと" do
      published_cafe = create_cafe(name: "札幌公開カフェ", status: :published)
      draft_cafe = create_cafe(name: "札幌下書きカフェ", status: :draft)
      closed_cafe = create_cafe(name: "札幌閉店カフェ", status: :closed)

      get search_suggestions_cafes_path, params: { keyword: "札幌" }

      labels = JSON.parse(response.body).fetch("suggestions").map { |suggestion| suggestion.fetch("label") }

      expect(labels).to include(published_cafe.name)
      expect(labels).not_to include(draft_cafe.name)
      expect(labels).not_to include(closed_cafe.name)
    end

    it "候補数は最大10件まで返すこと" do
      11.times do |index|
        create_cafe(name: "候補カフェ#{index}", status: :published)
      end

      get search_suggestions_cafes_path, params: { keyword: "候補" }

      suggestions = JSON.parse(response.body).fetch("suggestions")

      expect(suggestions.size).to eq(10)
    end
  end
end
