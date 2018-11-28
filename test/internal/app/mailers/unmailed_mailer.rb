# extend ActionMailer::Base directly
# to prevent default to
class UnmailedMailer < ActionMailer::Base
  def hello
  end
end
