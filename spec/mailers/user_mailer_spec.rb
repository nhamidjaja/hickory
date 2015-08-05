require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  context 'welcome_email' do
    let(:user) { FactoryGirl.build(:user, email: 'phendy@readflyer.com') }

    it 'send email' do
      email = UserMailer.welcome_email(user).deliver_now

      expect(ActionMailer::Base.deliveries.empty?).to eq(false)
      expect(email.from).to eq(['phendy@readflyer.com'])
      expect(email.to).to eq(['phendy@readflyer.com'])
      expect(email.subject).to eq('Welcome to Read Flyer')
    end
  end
end
