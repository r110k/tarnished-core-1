class UserMailer < ApplicationMailer
  def welcome_email(code)
    @code = code
    mail(to: '354929394@qq.com', subject: "我是邮件主题")
  end
end
