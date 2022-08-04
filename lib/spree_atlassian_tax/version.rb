module SpreeAtlassianTax
  VERSION = '1.7.1'.freeze

  module_function

  # Returns the version of the currently loaded SpreeAtlassianTax as a
  # <tt>Gem::Version</tt>.
  def version
    Gem::Version.new VERSION
  end
end
