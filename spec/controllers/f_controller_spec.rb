require 'rails_helper'

RSpec.describe FController, type: :controller do
  describe 'GET #index' do
    context 'unsigned in user' do
      before { get :index }
      it { expect(response).to redirect_to(new_user_session_path) }
    end

    context 'signed in user' do
      login_user

      it 'queues job' do
        expect(FaveWorker).to receive(:perform_async)
          .with(
            current_user.id.to_s,
            'http://example.com/hello?source=xyz',
            kind_of(String),
            'Something headline',
            'https://a.com/b.jpg',
            '2015-12-06 16:35:02 +0700'
          ).once

        get :index,
            url: 'http://example.com/hello?source=xyz',
            title: 'Something headline',
            image_url: 'https://a.com/b.jpg',
            published_at: '2015-12-06 16:35:02 +0700'
      end
    end
  end

  describe 'GET #index' do
    context 'unsigned in user' do
      before { get :preview }
      it { expect(response).to redirect_to(new_user_session_path) }
    end

    context 'signed in user' do
      login_user

      it { expect(get :preview).to render_template(:preview) }

      describe 'content' do
        before do
          get :preview,
              url: 'http://example.com/hello?source=xyz',
              title: 'Something headline',
              image_url: 'https://a.com/b.jpg',
              published_at: '2015-12-06 16:35:02 +0700'
        end

        subject { assigns(:content) }

        it { is_expected.to be_a_new(Content) }
        it { expect(subject.url).to eq('http://example.com/hello') }
        it { expect(subject.title).to eq('Something headline') }
        it { expect(subject.image_url).to eq('https://a.com/b.jpg') }
        it { expect(subject.published_at).to be_a_kind_of(Time) }
      end
    end
  end
end
