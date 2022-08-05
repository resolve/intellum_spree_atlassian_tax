module SpreeAtlassianTax
  class AtlassianLog
    LOG_DIRECTORY = 'log'.freeze

    def initialize
      @logger = Logger.new(*logger_params)
    end

    def enabled?
      SpreeAtlassianTax::Config.log || SpreeAtlassianTax::Config.log_to_stdout
    end

    def info(message, object = nil)
      logger.info(log_data(message, object)) if enabled?
    end

    def debug(object, message = '')
      logger.debug(log_data(message, object)) if enabled?
    end

    def error(object, message = '')
      logger.error(log_data(message, object)) if enabled?
    end

    delegate :log_file_name, :log_frequency, to: 'SpreeAtlassianTax::Config'

    private

    attr_reader :logger

    def log_file_path
      Rails.root.join(LOG_DIRECTORY, log_file_name)
    end

    def logger_params
      return [STDOUT] if SpreeAtlassianTax::Config.log_to_stdout

      [log_file_path, log_frequency]
    end

    def log_data(message, object)
      "[ATLASSIAn] #{object_info(object)}#{log_message(message)}"
    end

    def object_info(object)
      return unless object

      "#{object.class} #{object.id} : #{object.number} "
    end

    def log_message(message)
      return message.to_json unless message.respond_to?(:status)

      "#{message.status} #{message.body.to_json}"
    end
  end
end
