require File.dirname(__FILE__) + '/adyen/helper.rb'
require File.dirname(__FILE__) + '/adyen/notification.rb'
require File.dirname(__FILE__) + '/adyen/return.rb'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Adyen

        mattr_accessor :service_url
        mattr_accessor :payment_type

        def self.payment_type
          @@payment_type ||= :select
        end

        def self.service_url
          subdomain = ActiveMerchant::Billing::Base.integration_mode == :test ? "test" : "live"
          "https://#{subdomain}.adyen.com/hpp/#{payment_type}.shtml"
        end

        def self.notification(post)
          Notification.new(post)
        end

        def self.return(query_string)
          Return.new(query_string)
        end
      end
    end
  end
end
