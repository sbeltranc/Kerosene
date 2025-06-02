# fyi: restart the server after changing this file

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "localhost:3001", "127.0.0.1:3001", "sodium.lat", "www.sodium.lat"

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end