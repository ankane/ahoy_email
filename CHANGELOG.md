## 1.0.0 [unreleased]

- Removed support for Rails < 4.2
- Transitioned to HMAC-SHA256 for signatures

Breaking changes

- UTM parameters, open tracking, and click tracking are not enabled by default
- Only sent emails are recorded
- Proc options are now executed in the context of the mailer and take no arguments
- Invalid options now throw an `ArgumentError`
- `AhoyEmail.track` was removed in favor of `AhoyEmail.default_options`

## 0.5.2

- Fixed secret token for Rails 5.2
- Added `heuristic_parse` option

## 0.5.1

- Fixed deprecation warning in Rails 5.2
- Added `unsubscribe_links` option
- Allow `message_model` to accept a proc
- Use `references` in migration

## 0.5.0

- Added support for Rails 5.1
- Added `invalid_redirect_url`

## 0.4.0

- Fixed `belongs_to` error in Rails 5
- Include `safely_block` gem without polluting global namespace

## 0.3.2

- Fixed deprecation warning for Rails 5
- Do not track content by default on fresh installations

## 0.3.1

- Fixed deprecation warnings
- Fixed `stack level too deep` error

## 0.3.0

- Added safely for error reporting
- Fixed error with `to`
- Prevent duplicate records when mail called multiple times

## 0.2.4

- Added `extra` option for extra attributes

## 0.2.3

- Save utm parameters
- Added `url_options`
- Skip tracking for `mailto` links
- Only set secret token if not already set

## 0.2.2

- Fixed secret token for Rails 4.1
- Fixed links with href
- Fixed message id for Rails 3.1

## 0.2.1

- Added `only` and `except` options

## 0.2.0

- Enable tracking when track is called by default

## 0.1.5

- Rails 3 fix

## 0.1.4

- Try not to rewrite unsubscribe links

## 0.1.3

- Added `to` and `mailer` fields
- Added subscribers for open and click events

## 0.1.2

- Added `AhoyEmail.track` (fix)

## 0.1.1

- Use secure compare for signature verification
- Fixed deprecation warnings

## 0.1.0

- First major release
