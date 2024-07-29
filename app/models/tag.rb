class Tag < ApplicationRecord
  belongs_to :user
  enum kind: { income: 1, expenses: 0 }
  paginates_per 25

  validates :name, presence: true
  validates :name, length: { maximum: 12 }
  validates :sign, presence: true
  validates :kind, presence: true
end
