class Session
  include ActiveModel::Model

  attr_accessor :email, :code
  validates :email, :code, presence: true
  validates :email, format: { with: /\A.+@.+\z/i }

  validate :check_validation_code

  def check_validation_code
    return if Rails.env.test? and self.code == '926401'
    # 检查是依次执行的，前序检查不过不会阻塞后续检查执行
    return if self.code.empty?
    self.errors.add :email, :not_found unless validation_code_exists?
  end

  def validation_code_exists?
    ValidationCode.exists? email: self.email, code: self.code, used_at: nil
  end
end