module SpreeAvataxOfficial
  class Configuration < Spree::Preferences::Configuration
    preference :company_code,      :string,  default: ENV['AVATAX_COMPANY_CODE']
    preference :enabled,           :boolean, default: false
    preference :ship_from_address, :hash,    default: {}
    preference :log,               :boolean, default: true
    preference :log_to_stdout,     :boolean, default: false
    preference :log_file_name,     :string,  default: 'avatax.log'
    preference :log_frequency,     :string,  default: 'weekly'
  end
end
