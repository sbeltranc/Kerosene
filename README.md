# Kerosene
just pretty much a remake of the Roblox APIs with Ruby on Rails & PostgreSQL

## how to run?
1. clone the repo
```sh
git clone https://github.com/sbeltranc/Kerosene
```

2. create a .env file with the next
```sh
RAILS_MASTER_KEY=
CLOUDFLARE_ZERO_TRUST_TOKEN=
```

3. configure the credentials with the respective wanted data
```sh
rails credentials:edit
```

4. run the images
```
docker compose up -d
```

## faq/tips
- you're supposed to run all migrations from rails with `rails db:migrate`
- you'll have to generate your own rails master key and create your own encrypted settings
- it's highly recommended to host this, if **you know what you're doing**, running this by default won't be as much use as knowing what this does
