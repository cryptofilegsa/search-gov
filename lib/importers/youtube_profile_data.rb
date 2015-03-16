module YoutubeProfileData
  def self.import_profile(url)
    url_type, resource_id = detect_url url

    case url_type
    when :channel
      import_profile_by_channel_id resource_id
    when :user
      import_profile_by_username resource_id.downcase
    else
      nil
    end
  end

  def self.detect_url(url)
    url = "https://#{url.strip}" unless url =~ %r[\Ahttps?://]i
    uri = URI.parse(url) rescue nil
    return [] unless uri

    if uri.host.present?
      reversed_domain = uri.host.downcase.split('.').reverse.slice(0, 2)
      return [] unless %w(com youtube) == reversed_domain
    end

    detect_url_type_and_id uri.path
  end

  def self.import_profile_by_username(username)
    channel_id = YoutubeAdapter.get_channel_id_by_username username
    import_profile_by_channel_id channel_id, username
  end

  def self.import_profile_by_channel_id(channel_id, title = nil)
    return unless channel_id.present?

    profile = YoutubeProfile.where(channel_id: channel_id).first_or_initialize

    if profile.new_record?
      title ||= YoutubeAdapter.get_channel_title channel_id
      profile.title = title
      profile = nil unless profile.save
    end
    profile
  end

  private

  def self.detect_url_type_and_id(path)
    paths = path.to_s.split('/').reject(&:blank?)

    if paths[0] =~ /\A(channel|user)\Z/i && paths[1].present?
      [paths[0].to_sym, paths[1].squish]
    elsif paths.length == 1
      [:user, paths[0].squish]
    else
      []
    end
  end
end
