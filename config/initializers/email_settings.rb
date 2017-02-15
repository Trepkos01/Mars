ActionMailer::Base.smtp_settings = {
    user_name: 'SMTP_Injection',
    password: '9172a807a47d0eb335a7233549a65371a24bca24',
    address: 'smtp.sparkpostmail.com',
    port: 587,
    enable_starttls_auto: true,
    format: :html,
    from: 'postmaster@mars-score.com'
}