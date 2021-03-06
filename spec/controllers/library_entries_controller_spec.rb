# rubocop:disable Metrics/LineLength
# == Schema Information
#
# Table name: library_entries
#
#  id                :integer          not null, primary key
#  finished_at       :datetime
#  media_type        :string           not null, indexed => [user_id], indexed => [user_id, media_id]
#  notes             :text
#  nsfw              :boolean          default(FALSE), not null
#  private           :boolean          default(FALSE), not null, indexed
#  progress          :integer          default(0), not null
#  progressed_at     :datetime
#  rating            :integer
#  reaction_skipped  :integer          default(0), not null
#  reconsume_count   :integer          default(0), not null
#  reconsuming       :boolean          default(FALSE), not null
#  started_at        :datetime
#  status            :integer          not null, indexed => [user_id]
#  time_spent        :integer          default(0), not null
#  volumes_owned     :integer          default(0), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  anime_id          :integer          indexed
#  drama_id          :integer          indexed
#  manga_id          :integer          indexed
#  media_id          :integer          not null, indexed => [user_id, media_type]
#  media_reaction_id :integer
#  user_id           :integer          not null, indexed, indexed => [media_type], indexed => [media_type, media_id], indexed => [status]
#
# Indexes
#
#  index_library_entries_on_anime_id                             (anime_id)
#  index_library_entries_on_drama_id                             (drama_id)
#  index_library_entries_on_manga_id                             (manga_id)
#  index_library_entries_on_private                              (private)
#  index_library_entries_on_user_id                              (user_id)
#  index_library_entries_on_user_id_and_media_type               (user_id,media_type)
#  index_library_entries_on_user_id_and_media_type_and_media_id  (user_id,media_type,media_id) UNIQUE
#  index_library_entries_on_user_id_and_status                   (user_id,status)
#
# Foreign Keys
#
#  fk_rails_a7e4cb3aba  (media_reaction_id => media_reactions.id)
#
# rubocop:enable Metrics/LineLength

require 'rails_helper'

RSpec.describe LibraryEntriesController, type: :controller do
  LIBRARY_ENTRY ||= { status: String, progress: Integer }.freeze
  let(:user) { create(:user) }
  let(:anime) { create(:anime) }

  describe '#index' do
    describe 'with filter[user_id]' do
      it 'should respond with a list of library entries' do
        3.times { create(:library_entry, user: user) }
        get :index, filter: { user_id: user }
        expect(response.body).to have_resources(LIBRARY_ENTRY.dup, 'libraryEntries')
      end
    end

    describe 'with filter[media_type] + filter[media_id]' do
      it 'should respond with a list of library entries' do
        3.times { create(:library_entry, media: anime) }
        get :index, filter: { media_id: anime.id, media_type: 'Anime' }
        expect(response.body).to have_resources(LIBRARY_ENTRY.dup, 'libraryEntries')
      end
    end

    describe 'with filter[user_id] + filter[media_type] + filter[media_id]' do
      it 'should respond with a single library entry as an array' do
        create(:library_entry, user: user, media: anime)
        3.times { create(:library_entry, user: build(:user), media: anime) }
        get :index, filter: { media_id: anime.id, media_type: 'Anime',
                              user_id: user }
        expect(response.body).to have_resources(LIBRARY_ENTRY.dup, 'libraryEntries')
        expect(JSON.parse(response.body)['data'].count).to eq(1)
      end
    end

    describe 'with logged in user' do
      it 'should respond with a single private library entry as an array' do
        sign_in(user)
        create(:library_entry, user: user, media: anime, private: true)
        3.times do
          create(:library_entry, user: build(:user), media: anime,
                                 private: true)
        end
        get :index, filter: { user_id: user.id }
        expect(response.body).to have_resources(LIBRARY_ENTRY.dup, 'libraryEntries')
        expect(JSON.parse(response.body)['data'].count).to eq(1)
      end

      it 'should respond with a list of library entries' do
        sign_in(user)
        create(:library_entry, user: user, media: anime, private: true)
        3.times { create(:library_entry, user: build(:user), media: anime) }
        get :index, filter: { user_id: user.id }
        expect(response.body).to have_resources(LIBRARY_ENTRY.dup, 'libraryEntries')
        expect(JSON.parse(response.body)['data'].count).to eq(1)
      end
    end
  end
end
