class Item < ApplicationRecord
  belongs_to :user
  enum kind: { income: 1, expenses: 0 }

  validates :amount, presence: true
  validates :kind, presence: true
  validates :tags_id, presence: true
  validates :happened_at, presence: true

  # 注意这里没有 s ， 是一个自定义检查 
  validate :check_tags_id_belong_to_user

  def check_tags_id_belong_to_user
    all_tags_ids = Tag.where({ user_id: self.user_id }).map(&:id)
    if self.tags_id & all_tags_ids != self.tags_id
      self.errors.add :tags_id, '使用了错误的标签'
    end
  end

end
