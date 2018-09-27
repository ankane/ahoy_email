class ApplicationMailer < ActionMailer::Base
  default from: "from@example.org",
          to: -> { (params && params[:to]) || "to@example.org" },
          subject: "Hello",
          body: "World"

  def mail_html(html)
    mail do |format|
      format.html { render plain: html }
    end
  end
end
