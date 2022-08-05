module SpreeAtlassianTax
  class Engine < Rails::Engine
    require 'spree/core'
    require 'avatax'

    isolate_namespace SpreeAtlassianTax
    engine_name 'spree_atlassian_tax'

    config.autoload_paths += %W[#{config.root}/lib]

    initializer 'spree_atlassian_tax.environment', before: :load_config_initializers do |_app|
      SpreeAtlassianTax::Config = SpreeAtlassianTax::Configuration.new
    end

    initializer 'spree.spree_atlassian_tax.calculators', after: 'spree.register.calculators' do |_app|
      Rails.application.config.spree.calculators.tax_rates << SpreeAtlassianTax::Calculator::AtlassianCalculator
    end

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare(&method(:activate).to_proc)
  end
end
