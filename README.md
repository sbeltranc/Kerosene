# Kerosene
Just pretty much a remake of the Roblox APIs with Ruby on Rails & PostgreSQL

## what is this exactly?
Kerosene is a full remake of the Roblox APIs endpoints made on Ruby on Rails, at first it might not be interesenting or useless, however by running Kerosene you're running pretty much all the required endpoints for running the Roblox Website by forwarding requests to the domain you're hosting Kerosene with.

Sounds complex? Lets don't get the started with the fact you can also make your own private servers with this with the Roblox Client, that's how depth into Kerosene goes.

## how do i use it?
There is no specific usage base, you can use Kerosene for multiple stuff, but it's mainly to make your own Roblox Private Server (like those Clash Of Clans with infinite gems and stuff) by patching the Roblox website (replacing all the JavaScript inside of it with the domain you're hosting Kerosene with) or the clients too (by also replacing the domains on the client with the domain you're hosting Kerosene with, this might be a lot more complex than the other one as you're handling with a 1M USD anticheat)

The best way to use it for "fun" is by going to [a docs archive from the Roblox API](https://apidocs.sixteensrc.zip/), and seeing how the requests are done for some apis on Users and Auth (there's only v1 on the Kerosene Users Service and v2 for the Kerosene Auth Service)

Here's an example for obtaining someone user data on the API:
```js
const res = await fetch("https://users.simuldev.com/v1/users/1")
const data = await res.json()

console.log(data);
```

This will return the User Id 1 information if it was created on the Kerosene API already, else it'll return `{"errors":[{"code":0,"message":"User not found","userFacingMessage":"User not found"}]}`

And now here's an example for creating an account
```js
const res = await fetch("https://users.simuldev.com/v2/signup", {
  method: "POST",
  body: JSON.stringify({
    username: "santiago",
    password: "!@$I!wswv0ajansA.a.sa",
    email: "santiago@gmail.com", // no other services are allowed for security reasons, check the v2/auth_controller.rb for more info
    captchaToken: "can be anything, its not checked on the current simuldev.com"
  })
});
```

The response will return `{ "userId": number }` if succesful and will set-cookie .ROBLOSECURITY as the session cookie for your account, congrants! You can now use this cookie for accesing authenticated APIs.

This can be actually really useful if you know what you're doing with this, and this can be useless or just a fun thing to play with if you really don't have any idea what this could be used for, it's recommendable just to stick with the Users API as it's the most easiest and understandable + web user friendly.

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
