# Ahoy Email

:postbox: Simple, powerful email tracking for Rails

You get:

- A history of emails sent to each user
- Open and click tracking
- Easy UTM tagging

Works with any email service.

:bullettrain_side: To manage unsubscribes, check out [Mailkick](https://github.com/ankane/mailkick)

:fire: To track visits and events, check out [Ahoy](https://github.com/ankane/ahoy) and [Ahoy Events](https://github.com/ankane/ahoy_events).

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

### Opens

An invisible pixel is added right before the `</body>` tag in HTML emails.

If the recipient has images enabled in his or her email client, the pixel is loaded and the open time recorded.

Use `track open: false` to skip this.

### Clicks

A redirect is added to links to track clicks in HTML emails.

````
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

## Customize

### Tracking
Skip tracking of attributes by removing them from the database. You can remove these attributes: 

- to
- content
- subject
- mailer

### Configuration 
There are 3 places to set options. Here’s the order of precedence.

#### Action

``` ruby
class UserMailer < ActionMailer::Base
  def welcome_email(user)
    # ...
    track user: user
    mail to: user.email
  end
end
```

#### Mailer

```ruby
class UserMailer < ActionMailer::Base
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
    # :message and :controller keys
    ahoy = event[:controller].ahoy
    ahoy.track "Email opened", message_id: event[:message].id
  end

  def click(event)
    # same keys as above, plus :url
    ahoy = event[:controller].ahoy
    ahoy.track "Email clicked", message_id: event[:message].id, url: event[:url]
  end

end

AhoyEmail.subscribers << EmailSubscriber.new
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

Use a different model

```ruby
AhoyEmail.message_model = UserMessage
```

## History

View the [changelog](https://github.com/ankane/ahoy_email/blob/master/CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/ahoy_email/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/ahoy_email/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features
