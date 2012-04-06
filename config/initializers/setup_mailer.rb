ActionMailer::Base.smtp_settings = {

  :address              => "smtp.gmail.com",
  :port                 => 587,
  :user_name            => "pdust272",
  :password             => "fredduck",
  :authentication       => "plain",
  :enable_starttls_auto => true

}
