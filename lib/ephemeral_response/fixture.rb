module EphemeralResponse
  class Fixture
    attr_accessor :response
    attr_reader :method, :uri, :created_at

    def self.fixtures
      @fixtures ||= {}
    end

    def self.clear
      @fixtures = {}
    end

    def self.find(uri, method)
      fixtures[Fixture.new(uri, method).identifier]
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

    def self.respond_to(uri, method)
      fixture = Fixture.new(uri, method)
      unless fixtures[fixture.identifier]
        fixture.response = yield
        fixture.save
        fixtures[fixture.identifier] = fixture
      end
      fixtures[fixture.identifier].response
    end

    def initialize(uri, method)
      @method = method
      @uri = uri
      @uri.normalize!
      @created_at = Time.now
      yield self if block_given?
    end

    def ==(other)
      %w(method uri created_at response).all? do |attribute|
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
      Digest::SHA1.hexdigest(normalized_name)[0..6]
    end

    def normalized_name
      normalized_path = uri.path.gsub(/\/$/, '').gsub('/', '-')
      [uri.host, method, normalized_path].join("_")
    end

    def path
      File.join(Configuration.fixture_directory, file_name)
    end

    def save
      FileUtils.mkdir_p Configuration.fixture_directory
      File.open(path, 'w') do |f|
        f.write to_yaml
      end
    end

    protected

    def generate_file_name
      "#{normalized_name}_#{identifier}.yml"
    end
  end
end
