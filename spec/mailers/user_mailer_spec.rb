# frozen_string_literal: true
require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe '.welcome' do
    let(:user) do
      FactoryGirl.build(
        :user,
        username: 'jd',
        email: 'x@yz.com',
        full_name: 'John Doe'
      )
    end
    let(:mail) { UserMailer.welcome(user) }

    it { expect(mail.from).to eq(['hello@readflyer.com']) }
    it { expect(mail.to).to eq(['x@yz.com']) }
    it { expect(mail.subject).to eq('Selamat Datang ke Fave, jd') }
    it { expect(mail.body.encoded).to include('John') }
  end
end
