module AhoyEmail
  class RedisSubscriber
    attr_reader :redis, :prefix

    def initialize(redis: nil, prefix: "ahoy_email")
      @redis = redis || Redis.new
      @prefix = prefix
    end

    def track_send(event)
      campaign_prefix = campaign_key(event[:campaign])
      redis.pipelined do
        redis.incr("#{campaign_prefix}:sends")
        redis.sadd(campaigns_key, event[:campaign])
      end
    end

    def track_click(event)
      campaign_prefix = campaign_key(event[:campaign])
      redis.pipelined do
        redis.incr("#{campaign_prefix}:clicks")
        redis.pfadd("#{campaign_prefix}:unique_clicks", event[:token])
      end
    end

    def stats(campaign = nil)
      if campaign
        # return nil instead of zeros if not a campaign
        if campaign_exists?(campaign)
          campaign_stats(campaign)
        end
      else
        campaigns.inject({}) do |memo, campaign|
          memo[campaign] = campaign_stats(campaign)
          memo
        end
      end
    end

    def campaigns
      redis.smembers(campaigns_key)
    end

    def campaign_exists?(campaign)
      redis.sismember(campaigns_key, campaign)
    end

    private

    def campaigns_key
      "#{prefix}:campaigns"
    end

    def campaign_key(campaign)
      "#{prefix}:campaigns:#{campaign}"
    end

    def campaign_stats(campaign)
      # scope
      sends = nil
      clicks = nil
      unique_clicks = nil

      campaign_prefix = campaign_key(campaign)
      redis.pipelined do
        sends = redis.get("#{campaign_prefix}:sends")
        clicks = redis.get("#{campaign_prefix}:clicks")
        unique_clicks = redis.pfcount("#{campaign_prefix}:unique_clicks")
      end

      {
        sends: sends.value.to_i,
        clicks: clicks.value.to_i,
        unique_clicks: unique_clicks.value,
        ctr: (100.0 * unique_clicks.value / sends.value.to_f).round(1)
      }
    end
  end
end
