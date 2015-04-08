module PrivatePub
  module Generators
    class InstallGenerator < Rails::Generators::Base
      def self.source_root
        File.dirname(__FILE__) + "/templates"
      end

      def copy_files
        template "private_pub.yml", "config/private_pub.yml"
        copy_file "private_pub.ru", "private_pub.ru"
      end
    end
  end
end
