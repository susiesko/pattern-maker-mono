FactoryBot.define do
  factory :bead_finish, class: 'Catalog::BeadFinish' do
    name { ["Matte", "Glossy", "Metallic", "Galvanized", "AB", "Luster"].sample }
  end
end