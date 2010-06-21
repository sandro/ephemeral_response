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
      if File.directory?(Configuration.fixture_directory)
        Dir.glob("#{Configuration.fixture_directory}/*.yml", &method(:load_fixture))
      end
      fixtures
    end

    def self.load_fixture(file_name)
      fixture = YAML.load_file file_name
      if fixture.expired?
        FileUtils.rm fixture.path
      else
        fixtures[fixture.identifier] = fixture
      end
    end

    def self.respond_to(uri, request)
      return yield if Configuration.white_list.include? uri.host
      fixture = Fixture.new(uri, request)
      unless fixtures[fixture.identifier]
        fixture.response = yield
        fixture.save
        fixtures[fixture.identifier] = fixture
      end
      fixtures[fixture.identifier].response
    end

    def initialize(uri, request)
      @uri = uri.normalize
      @request = deep_clone request
      @created_at = Time.now
      yield self if block_given?
    end

    def ==(other)
      %w(request_yaml uri created_at response).all? do |attribute|
        send(attribute) == other.send(attribute)
      end
    end

    def expired?
      (created_at + Configuration.expiration) < Time.now
    end

    def file_name
      @file_name ||= generate_file_name
    end

    def identifier
      Digest::SHA1.hexdigest("#{uri}#{request_yaml}")
    end

    def method
      request.method
    end

    def normalized_name
      [uri.host, method, fs_path].join("_")
    end

    def fs_path
      uri.path.gsub(/\/$/, '').gsub('/', '-')
    end

    def path
      File.join(Configuration.fixture_directory, file_name)
    end

    def request_yaml
      request.to_yaml
    end

    def save
      FileUtils.mkdir_p Configuration.fixture_directory
      File.open(path, 'w') do |f|
        f.write to_yaml
      end
    end

    protected

    def generate_file_name
      "#{normalized_name}_#{identifier[0..6]}.yml"
    end

    def deep_clone(object)
      Marshal.load(Marshal.dump(object))
    end

  end
end
