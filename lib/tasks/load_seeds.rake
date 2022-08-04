namespace :spree_atlassian_tax do
  desc 'Migrate from Spree Atlassian and create initial data.'
  task load_seeds: :environment do
    SpreeAtlassianTax::Seeder.new.seed!
  end
end
