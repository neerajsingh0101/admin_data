module AdminData

  module SetupConfig
    extend ActiveSupport::Concern

    module ClassMethods

      # See AdminData::Configuration for details.
      attr_accessor :configuration

      # Call this method to customize the behavior of admin_data .
      #
      # @example
      #   AdminData.config do |config|
      #     config.number_of_records_per_page = 20
      #   end
      def config
        self.configuration ||= Configuration.new
        block_given? ? yield(configuration) : configuration
      end
    end

  end
end
