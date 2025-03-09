FactoryBot.define do
  factory :bead_finish_link, class: 'Catalog::BeadFinishLink' do
    association :bead, factory: :bead
    association :finish, factory: :bead_finish
  end
end