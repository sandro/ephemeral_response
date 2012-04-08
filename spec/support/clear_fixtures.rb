module ClearFixtures
  module_function
  def clear_fixtures
    if Dir.exists?(EphemeralResponse::Configuration.fixture_directory)
      FileUtils.rm_rf(EphemeralResponse::Configuration.fixture_directory)
    end
    EphemeralResponse::Fixture.clear
  end
end
