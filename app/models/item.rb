class Item < ApplicationRecord
  enum kind: { income: 1, expenses: 0 }
end
