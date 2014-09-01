module TimeCard
  module DevPairParsing

    def developers
      cp_dev_pair.nil? ? [] : cp_dev_pair.split(%r[\W]).map { |dev| dev.strip.downcase }
    end
  end
end