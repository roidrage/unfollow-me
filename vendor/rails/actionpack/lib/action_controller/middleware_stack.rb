module ActionController
  class MiddlewareStack < Array
    class Middleware
      attr_reader :args, :block

      def initialize(klass, *args, &block)
        @klass = klass

        options = args.extract_options!
        if options.has_key?(:if)
          @conditional = options.delete(:if)
        else
          @conditional = true
        end
        args << options unless options.empty?

        @args = args
        @block = block
      end

      def klass
        if @klass.is_a?(Class)
          @klass
        else
          @klass.to_s.constantize
        end
      end

      def active?
        if @conditional.respond_to?(:call)
          @conditional.call
        else
          @conditional
        end
      end

      def ==(middleware)
        case middleware
        when Middleware
          klass == middleware.klass
        when Class
          klass == middleware
        else
          klass == middleware.to_s.constantize
        end
      end

      def inspect
        str = klass.to_s
        args.each { |arg| str += ", #{arg.inspect}" }
        str
      end

      def build(app)
        if block
          klass.new(app, *args, &block)
        else
          klass.new(app, *args)
        end
      end
    end

    def initialize(*args, &block)
      super(*args)
      block.call(self) if block_given?
    end

    def use(*args, &block)
      middleware = Middleware.new(*args, &block)
      push(middleware)
    end

    def active
      find_all { |middleware| middleware.active? }
    end

    def build(app)
      active.reverse.inject(app) { |a, e| e.build(a) }
    end
  end
end
