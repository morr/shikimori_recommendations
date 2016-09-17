describe RecommendationIgnoresController do
  let(:user) { create :user }
  before { sign_in user }
  after { BannedRelations.instance.clear_cache! }

  describe '#create' do
    let(:anime) { create :anime, :special }

    before { post :create, target_type: Anime.name, target_id: anime.id }

    it { expect(response).to have_http_status :success }
    it { expect(response.content_type).to eq 'application/json' }
    it { expect(json).to eql [anime.id] }
  end

  describe '#cleanup' do
    let(:anime1) { create :anime, :special }
    let(:anime2) { create :anime }
    let(:anime3) { create :anime }
    before do
      create :recommendation_ignore, user: user, target: create(:manga)
      create :recommendation_ignore, user: user, target: anime1
      create :recommendation_ignore, user: user, target: anime2
      create :recommendation_ignore, user: create(:user), target: anime3

      delete :cleanup, target_type: 'anime'
    end

    it { expect(response).to have_http_status :success }
    it { expect(RecommendationIgnore.blocked(Anime, user)).to be_empty }
  end
end
