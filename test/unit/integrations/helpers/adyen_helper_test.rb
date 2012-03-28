require 'test_helper'

class AdyenHelperTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def setup
    @helper = Adyen::Helper.new('order-500','cody@example.com', :amount => 500, :currency => 'USD')
  end

  def test_basic_helper_fields
    assert_field 'merchantAccount',   'cody@example.com'
    assert_field 'paymentAmount',     '500'
    assert_field 'currencyCode',      'USD'
    assert_field 'merchantReference', 'order-500'
  end

  def test_customer_fields
    @helper.customer :email => 'cody@example.com'
    assert_field 'shopperEmail', 'cody@example.com'
  end

  def test_address_mapping
    @helper.billing_address :address1 => '1 My Street',
                            :address2 => '',
                            :city => 'Leeds',
                            :state => 'Yorkshire',
                            :zip => 'LS2 7EE',
                            :country  => 'CA'

    assert_field 'billingAddress.street',          '1 My Street'
    assert_field 'billingAddress.city',            'Leeds'
    assert_field 'billingAddress.stateOrProvince', 'Yorkshire'
    assert_field 'billingAddress.postalCode',      'LS2 7EE'
  end

  def test_custom_currency
    @helper = Adyen::Helper.new('order-500','cody@example.com', :amount => 500, :currency => 'EUR')
    assert_field 'currencyCode',      'EUR'
  end

  def test_custom_currency
    session_validity = DateTime.parse("2011-03-01 22:16:30 +02:00")
    ship_before_date = Date.today+1
    @helper = Adyen::Helper.new('order-500','cody@example.com', :amount => 500, :currency => 'EUR', :allowed_methods=>"ideal", :session_validity=>session_validity, :ship_before_date=>ship_before_date)
    assert_field 'allowedMethods', "ideal"
    assert_field 'sessionValidity', session_validity.to_s
    assert_field 'shipBeforeDate', ship_before_date.to_s
  end
end
