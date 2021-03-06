class UserMailer < ActionMailer::Base

  layout 'email'

  default from: "Cloudsdale <noreply@cloudsdale.org>",
          return_path: 'Cloudsdale Support <ask@cloudsdale.org>',
          css:  :email

  def restore_mail(user_id)

    user    = User.find(user_id)
    url     = restore_users_url(user.restoration.token)
    subject = "Cloudsdale Account Restoration"

    mail(to: user.email, subject: subject) do |format|
      format.text { render 'restore_mail.text.erb',   locals: { user: user, url: url }, layout: false }
      format.html { render 'restore_mail.html.haml',  locals: { user: user, url: url, subject: subject } }
    end

  end

  def welcome_mail(user_id)
    user = User.find(user_id)
    url  = verify_email_url(user.email_token)
    subject = "Welcome to Cloudsdale"

    mail(to: user.email, subject: subject) do |format|
      format.text { render 'welcome_mail.text.erb',   locals: { user: user, url: url }, layout: false }
      format.html { render 'welcome_mail.html.haml',  locals: { user: user, url: url, subject: subject } }
    end
  end

  def verification_mail(user_id)
    user = User.find(user_id)
    url  = verify_email_url(user.email_token)
    subject = "Cloudsdale email verification"

    mail(to: user.email, subject: subject) do |format|
      format.text { render 'verification_mail.text.erb',   locals: { user: user, url: url }, layout: false }
      format.html { render 'verification_mail.html.haml',  locals: { user: user, url: url, subject: subject } }
    end
  end

end
