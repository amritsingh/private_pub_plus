# Run with: rackup private_pub.ru -s thin -E production
require "bundler/setup"
require "yaml"
require "faye"
require "private_pub"

module PrivatePubPlus
  # This class is an extension for the Faye::RackAdapter.
  # It is used inside of PrivatePubPlus.faye_app.
  class FayeExtension
    # Callback to handle incoming Faye messages. This authenticates both
    # subscribe and publish calls.
    def incoming(message, callback)
      if message["channel"] == "/meta/subscribe"
        authenticate_subscribe(message)
      elsif message["channel"] !~ %r{^/meta/}
        authenticate_publish(message)
      end
      callback.call(message)
    end

    private
    def authenticate_subscribe(message)
      # TODO:
      # Code to authenticate the subscribe message.
    end

    def authenticate_publish(message)
      # TODO:
      # Code to authenticate the publish message
      if PrivatePubPlus.config[:secret_token].nil?
        raise Error, "No secret_token config set, ensure private_pub.yml is loaded properly."
      elsif message["ext"]["private_pub_token"] != PrivatePubPlus.config[:secret_token]
        message["error"] = "Incorrect token."
      else
        message["ext"]["private_pub_token"] = nil
      end
    end
  end
end

Faye::WebSocket.load_adapter('thin')

PrivatePubPlus.load_config(File.expand_path("../config/private_pub.yml", __FILE__), ENV["RAILS_ENV"] || "development")
run PrivatePubPlus.faye_app
