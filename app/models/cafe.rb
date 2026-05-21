class Cafe < ApplicationRecord
  enum :status, { draft: 0, published: 1, closed: 2 }
end
