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

Ahoy creates an `Ahoy::Message` record when an email is sent.

### Open

An invisible pixel is added right before the closing `</body>` tag to HTML emails.

If a recipient has images enabled in his / her email client, the pixel is loaded and an open is recorded.

### Click

Links in HTML emails are rewritten to pass through your server.

````
http://chartkick.com
```

becomes

```
http://yoursite.com/ahoy/messages/rAnDoMtOken/click?url=http%3A%2F%2Fchartkick.com&signature=...
```

A signature is added to prevent [open redirects](https://www.owasp.org/index.php/Open_redirect).

Keep specific links from being tracked with `<a data-disable-tracking="true" href="..."></a>`.

### UTM Parameters

UTM parameters are added to each link if they don’t already exist.

By default, `utm_medium` is set to `email`.

### User

To specify the user, use:

```ruby
class UserMailer < ActionMailer::Base
  def welcome_email(user)
    # ...
    ahoy user: user
    mail to: user.email
  end
end
```

User is [polymorphic](http://railscasts.com/episodes/154-polymorphic-association), so use it with any model.

## Customize

There are 3 places to set options.

### Global

The defaults are listed below.

```ruby
AhoyEmail.options = {
  create_message: true,
  track_open: true,
  track_click: true,
  utm_source: nil,
  utm_medium: "email",
  utm_term: nil,
  utm_content: nil,
  utm_campaign: nil
}
```

### Mailers

```ruby
class UserMailer < ActionMailer::Base
  ahoy utm_campaign: "boom"
end
```

### Action

``` ruby
class UserMailer < ActionMailer::Base
  def welcome_email(user)
    # ...
    ahoy user: user
    mail to: user.email
  end
end
```

## TODO

- Subscription management (lists, opt-outs) [separate gem]

## History

View the [changelog](https://github.com/ankane/ahoy_email/blob/master/CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/ahoy_email/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/ahoy_email/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features
