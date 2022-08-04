module AtlassianTax::Api::Transactions

  def create_or_adjust_transaction(model, options={})
    path = '/finsys/api/1/avalara/transactions/createoradjust'
    post(path, model, options)
  end

  def create_transaction(model, options={})
    path = '/finsys/api/1/avalara/transactions/createoradjust'
    post(path, model, options)
  end
end
