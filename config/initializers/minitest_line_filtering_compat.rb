# frozen_string_literal: true

# Rails 8 line filtering expects Minitest with a compatible run signature.
# Provide a compatibility shim for Minitest 6.0.x.
module Rails
  module LineFiltering
    def run(*args, **kwargs)
      if args.length <= 2
        reporter = args[0]
        options = args[1] || {}
        options = options.merge(filter: Rails::TestUnit::Runner.compose_filter(self, options[:filter]))
        return super(reporter, options)
      end

      super
    end
  end
end
