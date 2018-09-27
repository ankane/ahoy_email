# require_relative "test_helper"

# class UserMailer < ActionMailer::Base
#   default from: "from@example.com"
#   after_action :prevent_delivery_to_guests, only: [:welcome2]

#   def welcome
#     mail to: "test@example.org", subject: "Hello", body: "World"
#   end

#   def welcome2
#     mail to: "test@example.org", subject: "Hello", body: "World"
#   end

#   def welcome3
#     track message: false
#     mail to: "test@example.org", subject: "Hello", body: "World"
#   end

#   def welcome4
#     mail_html('<a href="https://example.org">Hi<a>')
#   end

#   def welcome5
#     mail_html('<a href="https://example.org?baz[]=1&amp;baz[]=2">Hi<a>')
#   end

#   def heuristic_parse
#     track heuristic_parse: true
#     mail_html('<a href="example.org">Hi<a>')
#   end

#   def mailto
#     track heuristic_parse: true
#     mail_html('<a href="mailto:someone@yoursite.com">Email Us</a>')
#   end

#   def app_link
#     track heuristic_parse: true
#     mail_html('<a href="fb://profile/33138223345">Email Us</a>')
#   end

#   def welcome4_heuristic
#     track heuristic_parse: true
#     mail_html('<a href="https://example.org">Hi<a>')
#   end

#   def welcome5_heuristic
#     track heuristic_parse: true
#     mail_html('<a href="https://example.org?baz[]=1&amp;baz[]=2">Hi<a>')
#   end

#   private

#   def prevent_delivery_to_guests
#     mail.perform_deliveries = false
#   end

#   def mail_html(html)
#     track click: false
#     mail to: "test@example.org", subject: "Hello" do |format|
#       format.html { render plain: html }
#     end
#   end
# end

# class MailerTest < Minitest::Test
#   def test_heuristic_parse
#     # Should convert the URI fragment into a URI
#     message = UserMailer.heuristic_parse
#     body = message.body.to_s
#     assert_match "http://example.org", body
#   end

#   def test_mailto
#     # heuristic parse should ignore the mailto link
#     message = UserMailer.mailto
#     body = message.body.to_s
#     assert_match "<a href=\"mailto:someone@yoursite.com\">", body
#   end

#   def test_app_link
#     # heuristic parse should ignore the app link
#     message = UserMailer.app_link
#     body = message.body.to_s
#     assert_match "<a href=\"fb://profile/33138223345\">", body
#   end

#   def test_utm_params_heuristic_parse
#     # heuristic parse should not have unexpected side effects
#     message = UserMailer.welcome4_heuristic
#     body = message.body.to_s
#     assert_match "utm_campaign=welcome4", body
#     assert_match "utm_medium=email", body
#     assert_match "utm_source=user_mailer", body
#   end

#   def test_array_params_heuristic_parse
#     # heuristic parse should not have unexpected side effects
#     message = UserMailer.welcome5_heuristic
#     body = message.body.to_s
#     assert_match "baz%5B%5D=1&amp;baz%5B%5D=2", body
#   end

#   private

#   def assert_message(method)
#     UserMailer.send(method).deliver_now
#     ahoy_message = Ahoy::Message.first
#     assert_equal 1, Ahoy::Message.count
#     assert_equal "test@example.org", ahoy_message.to
#     assert_equal "UserMailer##{method}", ahoy_message.mailer
#     assert_equal "Hello", ahoy_message.subject
#     assert_equal "user_mailer", ahoy_message.utm_source
#     assert_equal "email", ahoy_message.utm_medium
#     assert_equal method.to_s, ahoy_message.utm_campaign
#   end
# end
