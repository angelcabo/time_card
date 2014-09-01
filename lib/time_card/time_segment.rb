module TimeCard
  class TimeSegment
    include TimeCard::DevPairParsing

    attr_accessor :start_time, :end_time, :status, :cp_dev_pair

    def initialize(card_version = nil)
      @status = card_version.cp_status
      @cp_dev_pair = card_version.cp_dev_pair
      @start_time = card_version.updated_at
    end

    def has_ended_with_version?(version)
      version.cp_status != @status || version.cp_dev_pair != @cp_dev_pair
    end

    def developed_by?(developer)
      @status.try(:downcase) == 'in development' && developers.include?(developer.name.downcase)
    end
  end
end