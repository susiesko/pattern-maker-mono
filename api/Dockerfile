# ---- Ruby base image ----
FROM ruby:3.2.2 AS base

# Set environment variables
ENV RAILS_ENV=production \
    BUNDLE_WITHOUT="development:test" \
    BUNDLE_DEPLOYMENT=true

# Install dependencies
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy Gemfiles and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local deployment 'false' && \
    bundle config set --local without 'development test' && \
    bundle install --jobs 4 --retry 3

# Copy application code
COPY . .

# Try to precompile assets (skip if no assets exist for API-only apps)
RUN bundle exec rake assets:precompile 2>/dev/null || echo "No assets to precompile"

# Expose port 8080 for Fly
EXPOSE 8080

# Start the server
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
