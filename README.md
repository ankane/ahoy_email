# Ahoy Email

First-party email analytics for Rails

**Ahoy Email 2.0 was recently released** - see [how to upgrade](#upgrading)

:fire: For web and native app analytics, check out [Ahoy](https://github.com/ankane/ahoy)

:bullettrain_side: To manage unsubscribes, check out [Mailkick](https://github.com/ankane/mailkick)

[![Build Status](https://github.com/ankane/ahoy_email/workflows/build/badge.svg?branch=master)](https://github.com/ankane/ahoy_email/actions)

## Installation

Add this line to your application’s Gemfile:

```ruby
gem 'ahoy_email'
```

## Getting Started

There are three main features, which can be used independently:

- [Message history](#message-history)
- [UTM tagging](#utm-tagging)
- [Click analytics](#click-analytics)

## Message History

To encrypt email addresses with Lockbox, install [Lockbox](https://github.com/ankane/lockbox) and [Blind Index](https://github.com/ankane/blind_index) and run:

```sh
rails generate ahoy:messages --encryption=lockbox
rails db:migrate
```

To use Active Record encryption (Rails 7+, experimental), run:

```sh
rails generate ahoy:messages --encryption=activerecord
rails db:migrate
```

If you prefer not to encrypt data, run:

```sh
rails generate ahoy:messages --encryption=none
rails db:migrate
```

Then, add to mailers:

```ruby
class CouponMailer < ApplicationMailer
  has_history
end
```

Use the `Ahoy::Message` model to query messages:

```ruby
Ahoy::Message.last
```

Use only and except to limit actions

```ruby
class CouponMailer < ApplicationMailer
  has_history only: [:welcome]
end
```

To store history for all mailers, create `config/initializers/ahoy_email.rb` with:

```ruby
AhoyEmail.default_options[:message] = true
```

### Users

By default, Ahoy Email tries `@user` then `params[:user]` then `User.find_by(email: message.to)` to find the user. You can pass a specific user with:

```ruby
class CouponMailer < ApplicationMailer
  has_history user: -> { params[:some_user] }
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

### Extra Data

Add extra data to messages. Create a migration like:

```ruby
class AddCouponIdToAhoyMessages < ActiveRecord::Migration[6.1]
  def change
    add_column :ahoy_messages, :coupon_id, :integer
  end
end
```

And use:

```ruby
class CouponMailer < ApplicationMailer
  has_history extra: {coupon_id: 1}
end
```

You can use a proc as well.

```ruby
class CouponMailer < ApplicationMailer
  has_history extra: -> { {coupon_id: params[:coupon].id} }
end
```

### Options

Set global options

```ruby
AhoyEmail.default_options[:user] = -> { params[:admin] }
```

Use a different model

```ruby
AhoyEmail.message_model = -> { UserMessage }
```

Or fully customize how messages are tracked

```ruby
AhoyEmail.track_method = lambda do |data|
  # your code
end
```

### Data Retention

Delete older data with:

```ruby
Ahoy::Message.where("created_at < ?", 1.year.ago).in_batches.delete_all
```

Delete data for a specific user with:

```ruby
Ahoy::Message.where(user_id: 1, user_type: "User").in_batches.delete_all
```

## UTM Tagging

Use UTM tagging to attribute visits or conversions to an email campaign. Add UTM parameters to links with:

```ruby
class CouponMailer < ApplicationMailer
  utm_params
end
```

The defaults are:

- `utm_medium` - `email`
- `utm_source` - the mailer name like `coupon_mailer`
- `utm_campaign` - the mailer action like `offer`

You can customize them with:

```ruby
class CouponMailer < ApplicationMailer
  utm_params utm_campaign: -> { "coupon#{params[:coupon].id}" }
end
```

Use only and except to limit actions

```ruby
class CouponMailer < ApplicationMailer
  utm_params only: [:welcome]
end
```

Skip specific links with:

```erb
<%= link_to "Go", some_url, data: {skip_utm_params: true} %>
```

## Click Analytics

You can track click-through rate to see how well campaigns are performing. Stats can be stored in your database, Redis, or any other data store.

#### Database

Run:

```sh
rails generate ahoy:clicks
rails db:migrate
```

And create `config/initializers/ahoy_email.rb` with:

```ruby
AhoyEmail.subscribers << AhoyEmail::DatabaseSubscriber
AhoyEmail.api = true
```

#### Redis

Add this line to your application’s Gemfile:

```ruby
gem 'redis'
```

And create `config/initializers/ahoy_email.rb` with:

```ruby
# pass your Redis client if you already have one
AhoyEmail.subscribers << AhoyEmail::RedisSubscriber.new(redis: Redis.new)
AhoyEmail.api = true
```

#### Other

Create `config/initializers/ahoy_email.rb` with:

```ruby
class EmailSubscriber
  def track_send(data)
    # your code
  end

  def track_click(data)
    # your code
  end

  def stats(campaign)
    # optional, for AhoyEmail.stats
  end
end

AhoyEmail.subscribers << EmailSubscriber
AhoyEmail.api = true
````

### Usage

Add to mailers you want to track

```ruby
class CouponMailer < ApplicationMailer
  track_clicks campaign: "my-campaign"
end
```

If storing stats in the database, the mailer should also use `has_history`

Use only and except to limit actions

```ruby
class CouponMailer < ApplicationMailer
  track_clicks campaign: "my-campaign", only: [:welcome]
end
```

Or make it conditional

```ruby
class CouponMailer < ApplicationMailer
  track_clicks campaign: "my-campaign", if: -> { params[:user].opted_in? }
end
```

You can also use a proc

```ruby
class CouponMailer < ApplicationMailer
  track_clicks campaign: -> { "coupon-#{action_name}" }
end
```

Skip specific links with:

```erb
<%= link_to "Go", some_url, data: {skip_click: true} %>
```

By default, unsubscribe links are excluded. To change this, use:

```ruby
AhoyEmail.default_options[:unsubscribe_links] = true
```

You can specify the domain to use with:

```ruby
AhoyEmail.default_options[:url_options] = {host: "mydomain.com"}
```

### Stats

Get stats for a campaign

```ruby
AhoyEmail.stats("my-campaign")
```

## Upgrading

### 2.0

Ahoy Email 2.0 brings a number of changes. Here are a few to be aware of:

- The `to` field is encrypted by default for new installations. If you’d like to encrypt an existing installation, install [Lockbox](https://github.com/ankane/lockbox) and [Blind Index](https://github.com/ankane/blind_index) and follow the Lockbox instructions for [migrating existing data](https://github.com/ankane/lockbox#migrating-existing-data).

  For the model, create `app/models/ahoy/message.rb` with:

  ```ruby
  class Ahoy::Message < ActiveRecord::Base
    self.table_name = "ahoy_messages"

    belongs_to :user, polymorphic: true, optional: true

    encrypts :to, migrating: true
    blind_index :to, migrating: true
  end
  ```

- The `track` method has been broken into:

  - `has_history` for message history
  - `utm_params` for UTM tagging
  - `track_clicks` for click analytics

- Message history is no longer enabled by default. Add `has_history` to individual mailers, or create an initializer with:

  ```ruby
  AhoyEmail.default_options[:message] = true
  ```

- For privacy, open tracking has been removed.

- For clicks, we encourage you to try [aggregate analytics](#click-analytics) to measure the performance of campaigns. You can use a library like [Rollup](https://github.com/ankane/rollup) to aggregate existing data, then drop the `token` and `clicked_at` columns.

  To keep individual analytics, use `has_history` and `track_clicks campaign: false` and create an initializer with:

  ```ruby
  AhoyEmail.save_token = true
  AhoyEmail.subscribers << AhoyEmail::MessageSubscriber
  ```

  If you use a custom subscriber, `:message` is no longer included in click events. You can use `:token` to query the message if needed.

- Users are shown a link expired page when signature verification fails instead of being redirected to the homepage when `AhoyEmail.invalid_redirect_url` is not set

## History

View the [changelog](https://github.com/ankane/ahoy_email/blob/master/CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/ahoy_email/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/ahoy_email/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features

To get started with development:

```sh
git clone https://github.com/ankane/ahoy_email.git
cd ahoy_email
bundle install
bundle exec rake test
```
