# Seed Files

This directory contains individual seed files for different data categories in the application.

## Available Seed Files

- `bead_brands.rb` - Seeds bead brands (Miyuki, Toho, Preciosa)
- `bead_colors.rb` - Seeds basic bead colors
- `bead_types.rb` - Seeds bead types for different brands
- `bead_sizes.rb` - Seeds bead sizes for different bead types
- `bead_finishes.rb` - Seeds common bead finishes

## How to Use

### Seeding All Data

To seed all data at once, run:

```bash
rails db:seed
```

This will load all seed files in the `db/seeds` directory.

### Seeding Specific Data

To seed only specific data categories, use the `SEEDS` environment variable:

```bash
SEEDS=bead_brands,bead_colors rails db:seed
```

This will only load the specified seed files.

### Resetting the Database

To clear existing data before seeding (useful in development/testing):

```bash
RESET_DB=true rails db:seed
```

Or to reset only specific categories:

```bash
RESET_DB=true SEEDS=bead_brands,bead_colors rails db:seed
```

## Adding New Seed Files

1. Create a new Ruby file in the `db/seeds` directory
2. Follow the pattern of existing seed files
3. Use `find_or_create_by!` to ensure idempotence
4. The main `seeds.rb` file will automatically load your new seed file

## Dependencies

Some seed files depend on others. For example, `bead_types.rb` depends on `bead_brands.rb`. The recommended seeding order is:

1. bead_brands.rb
2. bead_colors.rb
3. bead_finishes.rb
4. bead_types.rb
5. bead_sizes.rb

When using the `SEEDS` environment variable, make sure to include dependencies in the correct order.