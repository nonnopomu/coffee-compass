class Tag < ApplicationRecord
  enum :category, { roast_level: 0, taste: 1, brew_method: 2, cafe_feature: 3 }
end
