module EphemeralResponse
  class Fixture
    attr_accessor :response
    attr_reader :request, :uri, :created_at, :body

    def self.fixtures
      @fixtures ||= {}
    end

    def self.clear
      @fixtures = {}
    end

    def self.find(uri, request, body = nil)
      fixtures[Fixture.new(uri, request, body).identifier]
    end

    def self.load_all
      clear
      if File.directory?(Configuration.fixture_directory)
        Dir.glob("#{Configuration.fixture_directory}/*.yml", &method(:load_fixture))
      end
      fixtures
    end

    def self.load_fixture(file_name)
      register YAML.load_file(file_name)
    end

    def self.find_or_initialize(uri, request, body = nil, &block)
      find(uri, request, body) || new(uri, request, body, &block)
    end

    def self.register(fixture)
      if fixture.expired?
        FileUtils.rm fixture.path
      else
        fixtures[fixture.identifier] = fixture
      end
    end

    def self.respond_to(uri, request, body, request_block)
      fixture = find_or_initialize(uri, request, body)
      if fixture.new?
        fixture.response = yield
        fixture.response.instance_variable_set(:@body, fixture.response.body.to_s)
        fixture.register
      elsif request_block
        request_block.call fixture.response
      end
      fixture.response
    end

    def initialize(uri, request, body = nil)
      @uri = uri.normalize
      @request = deep_dup request
      @created_at = Time.now
      @body = body
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

    def method
      request.method
    end

    def new?
      !self.class.fixtures.has_key?(identifier)
    end

    def normalized_name
      [uri.host, method, fs_path].compact.join("_").gsub(/[\/]/, '-')
    end

    def fs_path
      uri.path.dup.sub!(/^\/(.+)$/, '\1')
    end

    def path
      File.join(Configuration.fixture_directory, file_name)
    end

    def register
      unless Configuration.white_list.include? uri.host
        save
        self.class.register self
      end
    end

    def save
      FileUtils.mkdir_p Configuration.fixture_directory
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
      "#{uri_identifier}#{request.method}#{request.body}#{body}"
    end

    def generate_file_name
      "#{normalized_name}_#{identifier[0..6]}.yml"
    end

    def registered_identifier
      identity = Configuration.host_registry[uri.host].call(Request.new(uri, request)) and identity.to_s
    end
  end
end
