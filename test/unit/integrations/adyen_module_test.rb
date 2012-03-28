require 'test_helper'

class AdyenModuleTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def setup
    super
    ActiveMerchant::Billing::Base.integration_mode = :test
    Adyen.payment_type = nil
  end

  def test_notification_method
    assert_instance_of Adyen::Notification, Adyen.notification('name=cody')
  end

  def test_service_url_uses_live_host_in_live_integration_mode
    ActiveMerchant::Billing::Base.integration_mode = :live
    assert_match /live\.adyen\.com/, Adyen.service_url
  end

  def test_service_url_uses_test_host_in_test_integration_mode
    ActiveMerchant::Billing::Base.integration_mode = :test
    assert_match /test\.adyen\.com/, Adyen.service_url
  end

  def test_service_url_uses_select_when_payment_type_is_select
    Adyen.payment_type = :select
    assert_match /select\.shtml/, Adyen.service_url
  end

  def test_service_url_uses_pay_when_payment_type_is_pay
    Adyen.payment_type = :pay
    assert_match /pay\.shtml/, Adyen.service_url
  end
end
