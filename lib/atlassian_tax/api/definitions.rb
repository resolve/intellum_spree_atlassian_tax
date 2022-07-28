module AtlassianTax::Api::Definitions
  def list_regions_by_country(country, options={})
    path = "/finsys/api/1/avalara/definitions/countries/#{country}/regions"
    get(path, options)
  end

  def list_countries(options={})
    path = '/finsys/api/1/avalara/transactions/createoradjust'
    get(path, options)
  end

  def list_regions(options={})
    path = '/finsys/api/1/avalara/definitions/regions'
    get(path, options)
  end
end
