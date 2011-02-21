require 'base64'
require 'stringio'
require 'zlib'
require 'openssl'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Adyen
        class Helper < ActiveMerchant::Billing::Integrations::Helper

          # the values of these fields are concatenated, HMAC digested, Base64 encoded, and sent along with the POST data to make hoodwinkery difficult
          SIGNATURE_FIELDS = [
            :amount,               # Amount to pay in cents.
            :currency,             # ISO code of currency to pay in.
            :ship_before_date,     # Date before which order has to be shpped, in YYYY-MM-DD format.
            :merchant_reference,   # Merchant reference for payment. Max 80 characters.
            :skin_code,            # Skin code to use for the payment page (affects branding, available payment options).
            :account,              # Merchant account with Adyen.
            :session_validity,     # Time before which the payment has to be completed, in YYYY-MM-DDThh:mm:ssTZD. TZD is TimeZone Designator. Use Z or +hh:mm or -hh:mm.
            :shopper_email,        # (Optional) Email address of the shopper.
            :shopper_reference,    # (Optional) Unique identifier for shopper.
            :recurring_contract,   # (Optional/CVC-only) What type of recurring payment to use. ONECLICK is the only documented value.
            :allowed_methods,      # (Optional) One or more allowed payment methods. Comma-join them. Examples: visa,mc,ideal,paypal. Groups of methods can be used, too: card,bankTransfer. See account for all possible methods.
            :blocked_methods,      # (Optional) One or more blocked payment methods. Same deal as with allowedMethods.
            :shopper_statement,    # (Optional) Max 135 characters, limited to a-zA-Z0-9.,-?|
            :merchant_return_data, # (Optional) Max 128 characters. This is returned after the payment. Useful for sending session IDs and such around. Avoid if possible due to URL length limitations.
            :billing_address_type, # (Optional) Affects visiblity/change-ability of billing address details. nil=modifiable+visible, 1=unmodifiable+visible, 2=unmodifiable+invisible.
            :offset                # (Optional) Affects fraud scoring and likelyhood of payment being rejected. 100 blocks all payments, -150 allows almost all payments.
          ]

          # same as above but for the customer's street address, which is to be separately hashed, as specified by Adyen
          # country should be ISO 3166-1 alpha-2 format, see http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 )
          ADDRESS_SIGNATURE_FIELDS = %w( billing_address.street billing_address.house_number_or_name billing_address.city billing_address.postal_code billing_address.state_or_province billing_address.country )

          def initialize(order, account, options = {})
            super
          end

          # orderData is a string of HTML which is displayed along with the CC form
          # it is GZipped, Base64 encoded, and sent along with the POST data
          def set_order_data(value)
            str = StringIO.new
            gz = Zlib::GzipWriter.new str
            gz.write value
            gz.close
            @order_data = Base64.encode64(str.string()).gsub("\n","")
          end

          def shared_secret(value)
            @shared_secret = value
          end

          def form_fields
            @fields.merge!('merchantSig' => generate_signature)
            @fields.merge!('billingAddressSig' => generate_address_signature) if @billing_address
            @fields.merge!('orderData' => @order_data) if @order_data
            @fields
          end

          def generate_signature_string
            SIGNATURE_FIELDS.map { |key|
              value = @fields[key.to_s]
              case key.to_s
              when 'session_validity'
                value.to_time.utc.strftime("%Y-%m-%dT%H:%M:%S+00:00")
              when 'ship_before_date'
                value.to_date.strftime("%Y-%m-%d")
              else
                value
              end
            }.join("")
          end

          def generate_signature
            digest = OpenSSL::HMAC.digest(OpenSSL::Digest::SHA1.new, @shared_secret, generate_signature_string)
            return Base64.encode64(digest).strip
          end

          def generate_address_signature_string
          end

          mapping :account, 'merchantAccount'
          mapping :allowed_methods, 'allowedMethods'
          mapping :amount, 'paymentAmount'
          mapping :blocked_methods, 'blockedMethods'
          mapping :currency, 'currencyCode'
          mapping :customer, :email => 'shopperEmail'
          mapping :merchant_reference, 'merchantReference'
          mapping :merchant_return_data, 'merchantReturnData'
          mapping :offset, 'offset'
          mapping :order, 'merchantReference'
          mapping :order_data, 'orderData'
          mapping :recurring_contract, 'recurringContract'
          mapping :session_validity, 'sessionValidity'
          mapping :ship_before_date, 'shipBeforeDate'
          mapping :shopper_email, 'shopperEmail'
          mapping :shopper_locale, 'shopperLocale'
          mapping :shopper_reference, 'shopperReference'
          mapping :shopper_statement, 'shopperStatement'
          mapping :skin_code, 'skinCode'

          mapping :billing_address, :city     => 'billingAddress.city',
                                    :address1 => 'billingAddress.street',
                                    #:address2 => 'billingAddress.????',
                                    :state    => 'billingAddress.stateOrProvince',
                                    :zip      => 'billingAddress.postalCode',
                                    :country  => 'billingAddress.country', # This two-letter format: http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2#NL
                                    :type     => 'billingAddressType' # Yes, there is no '.' in there!

          mapping :cancel_return_url, ''
          mapping :description, ''
          mapping :notify_url, ''
          mapping :return_url, ''
          mapping :shipping, ''
          mapping :tax, ''


        end
      end
    end
  end
end
