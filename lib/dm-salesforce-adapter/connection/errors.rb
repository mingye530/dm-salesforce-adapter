class SalesforceAdapter::Connection
  module Errors
    class Error             < StandardError; end
    class FieldNotFound     < Error
      def initialize(field, resource)
        super("Field \"#{field}\" not defined for resource #{resource}")
      end
    end
    
    class LoginFailed       < Error; end
    class SessionTimeout    < Error; end
    class UnknownStatusCode < Error; end
    class ServerUnavailable < Error; end

    class SOAPError      < Error
      def initialize(message, result)
        @result = result
        super("#{message}: #{result_message}")
      end

      def records
        @result.to_a
      end

      def failed_records
        @result.reject {|r| r[:success]}
      end

      def successful_records
        @result.select {|r| r[:success]}
      end

      def result_message
        failed_records.map do |r|
          message_for_record(r)
        end.join("; ")
      end

      def message_for_record(record)
        [record[:errors]].flatten.map {|e| "#{e[:statusCode]}: #{e[:message]}"}.join(", ")
      end

      def server_unavailable?
        failed_records.any? do |record|
          [record[:errors]].flatten.any? {|e| e[:statusCode] == "SERVER_UNAVAILABLE"}
        end
      end
    end
    class CreateError    < SOAPError; end
    class QueryError     < SOAPError; end
    class DeleteError    < SOAPError; end
    class UpdateError    < SOAPError; end
  end
end
