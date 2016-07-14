# frozen_string_literal: true
class ApplicationMailer < ActionMailer::Base
  default from: '"Fave News App" <hello@readflyer.com>'
  layout 'mailer'
end
