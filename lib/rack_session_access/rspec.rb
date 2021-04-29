module RackSessionAccess
  module Rspec
    def set_rack_session(hash)
      data = ::RackSessionAccess.encode(hash)

      put ::RackSessionAccess.path, params: { data: data }
      get ::RackSessionAccess.path

      session_view = SessionView.new(response.body)
      session_view.has_content?('Rack session data')
    end

    def get_rack_session
      get ::RackSessionAccess.path + '.raw'
      session_view = SessionView.new(response.body)
      session_view.has_content?('Raw rack session data')

      ::RackSessionAccess.decode(session_view.raw_data)
    end

    def get_rack_session_key(key)
      get_rack_session.fetch(key)
    end

    class SessionView
      def initialize(body)
        @body = Nokogiri::XML(body)
      end

      def has_content?(text)
        body.css("h2:contains('#{text}')").any?
      end

      def raw_data
        body.xpath('//body/pre').text
      end

      private

      attr_reader :body
    end
  end
end
