class DrinkLog < ApplicationRecord
  enum :status, { published: 0, hidden: 1 }
end
