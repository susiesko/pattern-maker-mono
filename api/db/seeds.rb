# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Master seed file that loads all individual seed files

# Option to clear existing data (development/testing only)
if ENV['RESET_DB'] == 'true' && !Rails.env.production?
  puts 'Clearing existing data...'

  # Delete in proper order to respect foreign key constraints
  ActiveRecord::Base.transaction do
    # Join tables first
    Catalog::BeadColorLink.delete_all if defined?(Catalog::BeadColorLink)
    Catalog::BeadFinishLink.delete_all if defined?(Catalog::BeadFinishLink)

    # Then main tables
    Catalog::Bead.delete_all
    Catalog::BeadColor.delete_all
    Catalog::BeadFinish.delete_all
    Catalog::BeadSize.delete_all
    Catalog::BeadType.delete_all
    Catalog::BeadBrand.delete_all

    # User accounts
    User.delete_all if defined?(User)

    # Reset sequences
    tables = %w[beads bead_brands bead_colors bead_sizes bead_types bead_finishes users]
    tables.each do |table|
      begin
        ActiveRecord::Base.connection.execute("ALTER SEQUENCE #{table}_id_seq RESTART WITH 1;")
      rescue => e
        puts "Warning: Could not reset sequence for #{table}: #{e.message}"
      end
    end
  end
end

# Create default admin user (only in development)
if Rails.env.development? && defined?(User)
  admin_email = 'admin@example.com'
  unless User.exists?(email: admin_email)
    puts 'Creating default admin user...'
    User.create!(
      username: 'admin',
      email: admin_email,
      password: 'password123',
      password_confirmation: 'password123',
      first_name: 'Admin',
      last_name: 'User',
      admin: true
    )
  end
end

# Explicitly list seed files in the order they should be executed
seed_files = %w[bead_brands.rb bead_types.rb bead_sizes.rb bead_colors.rb bead_finishes.rb]

seed_files.each do |seed_file|
  filename = File.join(Rails.root, 'db', 'seeds', seed_file)
  if File.exist?(filename)
    puts "Loading seed file: #{File.basename(filename)}"
    load filename
  else
    puts "Warning: Seed file #{seed_file} not found."
  end
end

puts 'Seeding completed!'