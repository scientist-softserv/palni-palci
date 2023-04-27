Rails.application.config.to_prepare do
  Qa::Authorities::Local::FileBasedAuthority.prepend ::PrependFileBasedAuthority
end
