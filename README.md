# Ahoy Email

:postbox: Simple, powerful email tracking for Rails

You get:

- A history of emails sent to each user
- Open and click tracking
- Easy UTM tagging

Works with any email service.

:bullettrain_side: To manage unsubscribes, check out [Mailkick](https://github.com/ankane/mailkick)

:fire: To track visits and events, check out [Ahoy](https://github.com/ankane/ahoy)

[![Build Status](https://travis-ci.org/ankane/ahoy_email.svg?branch=master)](https://travis-ci.org/ankane/ahoy_email)

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

Ahoy tracks the user a message is sent to - not just the email address.  This gives you a full history of messages for each user, even if he or she changes addresses.

By default, Ahoy tries `User.where(email: message.to.first).first` to find the user.

You can pass a specific user with:

```ruby
class UserMailer < ApplicationMailer
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
class User < ApplicationRecord
  has_many :messages, class_name: "Ahoy::Message"
end
```

And run:

```ruby
user.messages
```

### Opens

An invisible pixel is added right before the `</body>` tag in HTML emails.

If the recipient has images enabled in his or her email client, the pixel is loaded and the open time recorded.

Use `track open: false` to skip this.

### Clicks

A redirect is added to links to track clicks in HTML emails.

```
http://chartkick.com
```

becomes

```
http://you.io/ahoy/messages/rAnDoMtOkEn/click?url=http%3A%2F%2Fchartkick.com&signature=...
```

A signature is added to prevent [open redirects](https://www.owasp.org/index.php/Open_redirect).

Use `track click: false` to skip tracking, or skip specific links with:

```html
<a data-skip-click="true" href="...">Can't touch this</a>
```

### UTM Parameters

UTM parameters are added to links if they don’t already exist.

The defaults are:

- utm_medium - `email`
- utm_source - the mailer name like `user_mailer`
- utm_campaign - the mailer action like `welcome_email`

Use `track utm_params: false` to skip tagging, or skip specific links with:


```html
<a data-skip-utm-params="true" href="...">Break it down</a>
```

### Extra Attributes

Create a migration to add extra attributes to the `ahoy_messages` table, for example:

```ruby
class AddCampaignIdToAhoyMessages < ActiveRecord::Migration
  def change
    add_column :ahoy_messages, :campaign_id, :integer
  end
end
```

Then use:

```ruby
track extra: {campaign_id: 1}
```

## Customize

### Tracking

Skip tracking of attributes by removing them from your model.  You can safely remove:

- to
- mailer
- subject
- content

### Configuration

There are 3 places to set options. Here’s the order of precedence.

#### Action

``` ruby
class UserMailer < ApplicationMailer
  def welcome_email(user)
    # ...
    track user: user
    mail to: user.email
  end
end
```

#### Mailer

```ruby
class UserMailer < ApplicationMailer
  track utm_campaign: "boom"
end
```

#### Global

```ruby
AhoyEmail.track open: false
```

## Events

Subscribe to open and click events. Create an initializer `config/initializers/ahoy_email.rb` with:

```ruby
class EmailSubscriber
  def open(event)
    # any code you want
  end

  def click(event)
    # any code you want
  end
end

AhoyEmail.subscribers << EmailSubscriber.new
```

Here’s an example if you use [Ahoy](https://github.com/ankane/ahoy) to track visits and events:

```ruby
class EmailSubscriber
  def open(event)
    event[:controller].ahoy.track "Email opened", message_id: event[:message].id
  end

  def click(event)
    event[:controller].ahoy.track "Email clicked", message_id: event[:message].id, url: event[:url]
  end
end

AhoyEmail.subscribers << EmailSubscriber.new
```

## Reference

You can use a `Proc` for any option.

```ruby
track utm_campaign: proc { |message, mailer| mailer.action_name + Time.now.year }
```

Disable tracking for an email

```ruby
track message: false
```

Or specific actions

```ruby
track only: [:welcome_email]
track except: [:welcome_email]
```

Or by default

```ruby
AhoyEmail.track message: false
```

Customize domain

```ruby
track url_options: {host: "mydomain.com"}
```

Use a different model

```ruby
AhoyEmail.message_model = UserMessage
```

## Upgrading

### 0.2.3

Optionally, you can store UTM parameters by adding `utm_source`, `utm_medium`, and `utm_campaign` columns to your message model.

## History

View the [changelog](https://github.com/ankane/ahoy_email/blob/master/CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/ahoy_email/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/ahoy_email/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features
