module Analytical
  module Modules
    class KissMetrics
      include Analytical::Modules::Base

      def initialize(options={})
        super
        check_js_url_key
        @tracking_command_location = :head_append
      end

      def init_javascript(location)
        init_location(location) do
          km_cookie_domain_line = options[:km_cookie_domain].present? ?
              "var KM_COOKIE_DOMAIN = \"#{options[:km_cookie_domain]}\";" : nil
          js = <<-HTML
          <!-- Analytical Init: KissMetrics -->
          <script type="text/javascript">
            #{km_cookie_domain_line}
            var _kmq = _kmq || [];
            function _kms(u){
              setTimeout(function(){
                var d = document, f = d.getElementsByTagName('script')[0],
                s = d.createElement('script');
                s.type = 'text/javascript'; s.async = true; s.src = u;
                f.parentNode.insertBefore(s, f);
              }, 1);
            }
            _kms('//i.kissmetrics.com/i.js');
            _kms('#{options[:js_url_key]}');
          </script>
          HTML
          js
        end
      end

      def identify(id, *args)
        data = args.first || {}
        km_id = data[:email] || id
        "_kmq.push([\"identify\", \"#{ km_id }\"]);"
      end

      def event(name, *args)
        data = args.first || {}
        "_kmq.push([\"record\", \"#{name}\", #{data.to_json}]);"
      end

      def set(data)
        return '' if data.blank?
        "_kmq.push([\"set\", #{data.to_json}]);"
      end

      def alias_identity(old_identity, new_identity)
        "_kmq.push([\"alias\", \"#{old_identity}\", \"#{new_identity}\"]);"
      end

    private

      def check_js_url_key
        if options[:js_url_key].nil?
          raise "You didn't provide a js_url_key for kiss_metrics. " +
            "Add one to your analytical.yml file so KissMetrics will work."
        end
      end

    end
  end
end
