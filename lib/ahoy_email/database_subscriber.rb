module AhoyEmail
  class DatabaseSubscriber
    def track_send(event)
      # use has_history to store on Ahoy::Messages
    end

    def track_click(event)
      Ahoy::Click.create!(campaign: event[:campaign], token: event[:token])
    end

    def stats(campaign)
      sends = Ahoy::Message.where(campaign: campaign).count
      result = Ahoy::Click.where(campaign: campaign).select("COUNT(*) AS clicks, COUNT(DISTINCT token) AS unique_clicks").to_a[0]
      clicks = result.clicks
      unique_clicks = result.unique_clicks

      if sends > 0 || clicks > 0
        {
          sends: sends,
          clicks: clicks,
          unique_clicks: unique_clicks,
          ctr: 100 * unique_clicks / sends.to_f
        }
      end
    end

    def campaigns
      Ahoy::Message.where.not(campaign: nil).distinct.pluck(:campaign)
    end
  end
end
