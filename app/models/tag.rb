class Tag < ApplicationRecord
  enum kind: { income: 1, expenses: 0 }

  validates :name, presence: true
  validates :sign, presence: true

  belongs_to :user
end
