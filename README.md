# Ahoy Email

:postbox: Simple, powerful email tracking for Rails

You get:

- A history of emails sent to each user
- Easy UTM tagging
- Open and click tracking

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
rails db:migrate
```

## How It Works

Ahoy creates an `Ahoy::Message` every time an email is sent by default.

### Users

Ahoy tracks the user a message is sent to - not just the email address. This gives you a full history of messages for each user, even if he or she changes addresses.

By default, Ahoy tries `params[:user]`, then `User.find_by(email: message.to.first)` to find the user.

You can pass a specific user with:

```ruby
class UserMailer < ApplicationMailer
  track user: -> { @some_user }
end
```

The user association is [polymorphic](https://railscasts.com/episodes/154-polymorphic-association), so use it with any model.

To get all messages sent to a user, add an association:

```ruby
class User < ApplicationRecord
  has_many :messages, class_name: "Ahoy::Message", as: :user
end
```

And run:

```ruby
user.messages
```

### Extra Attributes

Create a migration to add extra attributes to the `ahoy_messages` table. For example:

```ruby
class AddCouponIdToAhoyMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :ahoy_messages, :coupon_id, :integer
  end
end
```

Then use:

```ruby
class CouponMailer < ApplicationMailer
  track extra: {coupon_id: 1}
end
```

You can use a proc as well.

```ruby
class CouponMailer < ApplicationMailer
  track extra: -> { {coupon_id: params[:coupon].id} }
end
```

### UTM Parameters

Automatically add UTM parameters to links.

```ruby
class UserMailer < ApplicationMailer
  track utm_params: true # use only/except to limit actions
end
```

The defaults are:

- utm_medium - `email`
- utm_source - the mailer name like `user_mailer`
- utm_campaign - the mailer action like `welcome_email`

You can customize any with:

```ruby
class CouponMailer < ApplicationMailer
  track utm_params: true, utm_campaign: -> { "coupon_#{params[:coupon].id}" }
end
```

Skip specific links with:

```html
<a data-skip-utm-params="true" href="...">Break it down</a>
```

### Opens

```ruby
class UserMailer < ApplicationMailer
  track open: true # use only/except to limit actions
end
```

An invisible pixel is added right before the `</body>` tag in HTML emails. If the recipient has images enabled in his or her email client, the pixel is loaded and the open time recorded.

Use `track open: false` to skip this.

### Clicks

```ruby
class UserMailer < ApplicationMailer
  track click: true # use only/except to limit actions
end
```

A redirect is added to links to track clicks in HTML emails.

```
https://chartkick.com
```

becomes

```
https://yoursite.com/ahoy/messages/rAnDoMtOkEn/click?url=https%3A%2F%2Fchartkick.com&signature=...
```

A signature is added to prevent [open redirects](https://www.owasp.org/index.php/Open_redirect).

Skip specific links with:

```html
<a data-skip-click="true" href="...">Can't touch this</a>
```

## Customize

### Tracking

Skip tracking of attributes by removing them from your model. You can safely remove:

- to
- mailer
- subject
- content

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

Set global options

```ruby
AhoyEmail.default_options.merge!(
  user: -> { params[:admin] },
  utm_params: true
}
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

By default, unsubscribe links are excluded from tracking. To change this, use:

```ruby
track unsubscribe_links: true
```

Use a different model

```ruby
AhoyEmail.message_model = -> { UserMessage }
```

## Upgrading

### 1.0.0

Breaking changes

- UTM parameters, open tracking, and click tracking are not enabled by default. To enable, create an initializer with:

```ruby
AhoyEmail.api = true

AhoyEmail.default_options.merge!(
  open: true,
  click: true,
  utm_params: true
)

# or
AhoyEmail.configure do |config|
  config.open = true
  config.click = true
  config.utm_params = true
end
```

- Procs are now executed in the context of the mailer and take no arguments.

```ruby
# old
user: ->(mailer, message) { User.find_by(email: message.to.first) }

# new
user: -> { User.find_by(email: message.to.first) }
```

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
