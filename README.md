# Ahoy Email

:construction: Coming soon - May 1, 2014

:envelope: Simple, powerful email tracking for Rails

You get:

- A history of emails sent to each user
- Open and click tracking
- Easy UTM tagging

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

Ahoy creates an `Ahoy::Message` every time an email is sent by default.

### Users

Ahoy tracks the user a message is sent to (not just the email address).  This allows you to have a full history of messages for each user.

By default, Ahoy tries `User.where(email: message.to.first).first` to find the user.

You can pass a specific user with:

```ruby
class UserMailer < ActionMailer::Base
  def welcome_email(user)
    # ...
    track user: user
    mail to: user.email
  end
end
```

The user association is [polymorphic](http://railscasts.com/episodes/154-polymorphic-association), so use it with any model.

To get all messages sent to a user, add an association:

```ruby
class User < ActiveRecord::Base
  has_many :messages, class_name: "Ahoy::Message"
end
```

And run:

```ruby
user.messages
```

### Track Opens

An invisible pixel is added right before the closing `</body>` tag to HTML emails.

If a recipient has images enabled in his / her email client, the pixel is loaded and an open is recorded.

Use `track open: false` to skip this.

### Track Clicks

Links in HTML emails are rewritten to pass through your server.

````
http://chartkick.com
```

becomes

```
http://yoursite.com/ahoy/messages/rAnDoMtOken/click?url=http%3A%2F%2Fchartkick.com&signature=...
```

A signature is added to prevent [open redirects](https://www.owasp.org/index.php/Open_redirect).

Use `track click: false` to skip tracking, or skip specific links with:

```html
<a data-disable-tracking="true" href="..."></a>
```

### UTM Tagging

UTM parameters are added to each link if they don’t already exist.

The defaults are:

- utm_medium - `email`
- utm_source - the mailer name like `user_mailer`
- utm_campaign - the mailer action like `welcome_email`

Use `track utm_params: false` to skip tagging, or skip specific links with:


```html
<a data-disable-utm-params="true" href="..."></a>
```

## Customize

There are 3 places to set options. Here’s the order of precedence.

### Action

``` ruby
class UserMailer < ActionMailer::Base
  def welcome_email(user)
    # ...
    track user: user
    mail to: user.email
  end
end
```

### Mailer

```ruby
class UserMailer < ActionMailer::Base
  track utm_campaign: "boom"
end
```

### Global

```ruby
AhoyEmail.track open: false
```

## Reference

You can use a `Proc` for any option.

```ruby
track utm_campaign: proc{|message, mailer| mailer.action_name + Time.now.year }
```

Disable tracking for an email

```ruby
track message: false
```

Or by default

```ruby
AhoyEmail.track message: false
```

## TODO

- Add tests
- Subscription management (lists, opt-outs) [separate gem]

## History

View the [changelog](https://github.com/ankane/ahoy_email/blob/master/CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/ahoy_email/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/ahoy_email/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features
