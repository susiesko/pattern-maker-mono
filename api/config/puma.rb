max_threads = Integer(ENV.fetch("RAILS_MAX_THREADS", 5))
min_threads = Integer(ENV.fetch("RAILS_MIN_THREADS", max_threads))
threads min_threads, max_threads
workers Integer(ENV.fetch("WEB_CONCURRENCY", 1))
preload_app!

port ENV.fetch("PORT", 8080)
environment ENV.fetch("RACK_ENV", "production")
