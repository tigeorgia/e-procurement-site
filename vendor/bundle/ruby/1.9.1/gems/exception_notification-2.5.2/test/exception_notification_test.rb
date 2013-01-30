require 'test_helper'

class ExceptionNotificationTest < ActiveSupport::TestCase
  test "should have default ignored exceptions" do
    assert ExceptionNotifier.default_ignore_exceptions == [ActiveRecord::RecordNotFound, AbstractController::ActionNotFound, ActionController::RoutingError]
  end

  test "should have default sender address overriden" do
    assert ExceptionNotifier::Notifier.default_sender_address == %("Dummy Notifier" <dummynotifier@example.com>)
  end

  test "should have default email prefix overriden" do
    assert ExceptionNotifier::Notifier.default_email_prefix == "[Dummy ERROR] "
  end

  test "should have default sections" do
    assert ExceptionNotifier::Notifier.default_sections == %w(request session environment backtrace)
  end
end
