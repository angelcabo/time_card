module TimeCard
  class Card < ActiveRecord::Base
    self.abstract_class = true

    def time_segments
      segments = []
      segment = nil
      versions.each do |version|
        if segments.empty? || segment.has_ended_with_version?(version)
          unless segment.nil?
            segment.end_time = version.updated_at
            segments.push segment
          end
          segment = TimeCard::TimeSegment.new(version)
        end
      end
      segments
    end

    def to_s
      "#{number},#{name},#{cp_dev_pair},#{initiative.nil? ? 'UNKNOWN INITIATIVE' : initiative.name},#{initiative.nil? ? 'UNKNOWN INITIATIVE' : initiative.cp_oracle_code}"
    end

  end
end