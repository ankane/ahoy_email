class ChildMailer < ParentMailer
  has_history message: false, only: [:other]
end
