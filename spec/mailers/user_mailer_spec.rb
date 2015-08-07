require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe '.welcome' do
    let(:user) { FactoryGirl.build(:user, email: 'x@yz.com') }
    let(:mail) { UserMailer.welcome(user) }

    it { expect(mail.from).to eq(['hello@readflyer.com']) }
    it { expect(mail.to).to eq(['x@yz.com']) }
    it { expect(mail.subject).to eq('Welcome to Flyer') }
  end
end
