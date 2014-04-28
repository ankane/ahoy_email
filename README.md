# Ahoy Email

:construction: Coming soon - May 1, 2014

:envelope: Simple, powerful email tracking for Rails

Keep track of emails:

- sent
- opened
- clicked

## Installation

Add this line to your application’s Gemfile:

```ruby
gem 'ahoy_email'
```

And run the generator. This creates a model to store messages.

```sh
rails generate ahoy_email:install
rake db:migrate
```

## How It Works

Ahoy creates an `Ahoy::Message` record when an email is sent. It also adds:

- open tracking
- click tracking
- UTM parameters

To specify the user, use:

```ruby
mail user: user, subject: "Awesome!", to: "..."
```

## TODO

- Subscription management (lists, opt-outs)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/ahoy_email/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/ahoy_email/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features
