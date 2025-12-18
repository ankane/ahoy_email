require_relative "test_helper"

class SubscriberTest < ActionDispatch::IntegrationTest
  def test_database_subscriber
    Ahoy::Click.delete_all
    subscriber = AhoyEmail::DatabaseSubscriber.new

    with_subscriber(subscriber) do
      message = ClickMailer.history.deliver_now
      assert_body(/\bc=test/, message)

      click_link(message)
      click_link(message)
      click_link(message)

      ClickMailer.history.deliver_now

      expected_stats = {sends: 2, clicks: 3, unique_clicks: 1, ctr: 50}

      assert_equal expected_stats, AhoyEmail.stats("test")
      assert_nil AhoyEmail.stats("missing")

      assert_equal ["test"], subscriber.campaigns
    end
  end

  def test_redis_subscriber
    redis = Redis.new
    redis.flushdb
    subscriber = AhoyEmail::RedisSubscriber.new(redis: redis)

    with_subscriber(subscriber) do
      message = ClickMailer.basic.deliver_now
      assert_body(/\bc=test/, message)

      click_link(message)
      click_link(message)
      click_link(message)

      ClickMailer.basic.deliver_now

      expected_stats = {sends: 2, clicks: 3, unique_clicks: 1, ctr: 50}

      assert_equal({"test" => expected_stats}, subscriber.stats)
      assert_equal({"test" => expected_stats}, AhoyEmail.stats)
      assert_equal expected_stats, AhoyEmail.stats("test")
      assert_nil AhoyEmail.stats("missing")

      assert_equal ["test"], subscriber.campaigns
    end
  end

  def test_message_subscriber
    with_save_token do
      with_subscriber(AhoyEmail::MessageSubscriber) do
        message = ClickMailer.campaignless.deliver_now
        refute_body(/\bc=/, message)
        click_link(message)

        assert ahoy_message.clicked
        assert ahoy_message.clicked_at
      end
    end
  end

  def test_subscriber
    with_subscriber(EmailSubscriber) do
      message = ClickMailer.basic.deliver_now
      assert_equal 1, $send_events.size
      send_event = $send_events.first
      assert_equal "test", send_event[:campaign]

      click_link(message)

      assert_equal 1, $click_events.size
      click_event = $click_events.first
      assert_equal "test", click_event[:campaign]
      assert_equal "https://example.org", click_event[:url]
      assert click_event[:token]

      assert_equal({sends: 1, clicks: 1}, AhoyEmail.stats)
    end
  end

  def test_subscriber_instance
    with_subscriber(EmailSubscriber.new) do
      message = ClickMailer.basic.deliver_now
      click_link(message)

      assert_equal 1, $click_events.size
      click_event = $click_events.first
      assert_equal "test", click_event[:campaign]
      assert_equal "https://example.org", click_event[:url]
      assert click_event[:token]

      assert_equal({sends: 1, clicks: 1}, AhoyEmail.stats)
    end
  end

  def test_legacy_subscriber
    with_subscriber(LegacyEmailSubscriber) do
      message = ClickMailer.basic.deliver_now
      click_link(message)

      assert_equal 1, $click_events.size
      click_event = $click_events.first
      assert_equal "test", click_event[:campaign]
      assert_equal "https://example.org", click_event[:url]
      assert click_event[:token]

      assert_nil AhoyEmail.stats
    end
  end

  def with_subscriber(subscriber)
    $send_events = []
    $click_events = []
    with_value(AhoyEmail, :subscribers, [subscriber]) do
      yield
    end
  end
end
