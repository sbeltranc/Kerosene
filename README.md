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
