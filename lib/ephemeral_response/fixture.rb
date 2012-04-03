module EphemeralResponse
  class Fixture
    attr_accessor :response
    attr_reader :request, :uri, :created_at

    def self.fixtures
      @fixtures ||= {}
    end

    def self.clear
      @fixtures = {}
    end

    def self.find(uri, request)
      fixtures[Fixture.new(uri, request).identifier]
    end

    def self.load_all
      clear
      if File.directory?(Configuration.effective_directory)
        Dir.glob("#{Configuration.effective_directory}/*.yml", &method(:load_fixture))
      end
      fixtures
    end

    def self.load_fixture(file_name)
      return unless File.exist?(file_name)
      if fixture = YAML.load_file(file_name)
        register fixture
      else
        EphemeralResponse::Configuration.debug_output.puts "EphemeralResponse couldn't load fixture: #{file_name}"
      end
    end

    def self.find_or_initialize(uri, request, &block)
      find(uri, request) || new(uri, request, &block)
    end

    def self.register(fixture)
      if fixture.expired?
        FileUtils.rm_f fixture.path
      else
        fixtures[fixture.identifier] = fixture
      end
    end

    def self.respond_to(uri, request, request_block)
      fixture = find_or_initialize(uri, request)
      if fixture.new?
        fixture.response = yield
        fixture.response.instance_variable_set(:@body, fixture.response.body.to_s)
        fixture.register
      elsif request_block
        request_block.call fixture.response
      end
      fixture.response
    end

    def initialize(uri, request)
      @uri = uri.normalize
      @request = deep_dup request
      @created_at = Time.now
      yield self if block_given?
    end

    def expired?
      !Configuration.skip_expiration && (created_at + Configuration.expiration) < Time.now
    end

    def file_name
      @file_name ||= generate_file_name
    end

    def identifier
      Digest::SHA1.hexdigest(registered_identifier || default_identifier)
    end

    def http_method
      request.method
    end

    def new?
      !self.class.fixtures.has_key?(identifier)
    end

    def normalized_name
      [uri.host, http_method, fs_path].compact.join("_").gsub(/[\/]/, '-')
    end

    def fs_path
      uri.path.dup.sub!(/^\/(.+)$/, '\1')
    end

    def path
      File.join(Configuration.effective_directory, file_name)
    end

    def register
      unless Configuration.white_list.include? uri.host
        EphemeralResponse::Configuration.debug_output.puts "#{request.method} #{uri} saved as #{path}"
        save
        self.class.register self
      end
    end

    def save
      FileUtils.mkdir_p Configuration.effective_directory
      File.open(path, 'w') do |f|
        f.write to_yaml
      end
    end

    def uri_identifier
      if uri.query
        parts = uri.to_s.split("?", 2)
        parts[1] = parts[1].split('&').sort
        parts
      else
        uri.to_s
      end
    end

    protected

    def deep_dup(object)
      Marshal.load(Marshal.dump(object))
    end

    def default_identifier
      "#{uri_identifier}#{http_method}#{request.body}"
    end

    def generate_file_name
      "#{normalized_name}_#{identifier[0..6]}.yml"
    end

    def registered_identifier
      identity = Configuration.host_registry[uri.host].call(Request.new(uri, request)) and identity.to_s
    end
  end
end
