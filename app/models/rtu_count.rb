class RtuCount

  def self.count(index, type, query_body)
    ES::client_reader.count(index: index, type: type, body: query_body)["count"] rescue nil
  end

end