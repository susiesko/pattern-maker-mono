# Be sure to restart your server when you modify this file.

# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.
# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Use environment variable for allowed origins (security fix)
    origins ENV.fetch('ALLOWED_ORIGINS', '').split(',').map(&:strip).reject(&:empty?)

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ['Authorization']
  end
end
