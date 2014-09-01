module TimeCard
  class OveCard < Card
    extend QueryableOnMingle
    include DevPairParsing

    self.table_name = 'ove_2_cards'

    has_many :versions, -> { order 'version' }, class_name: 'OveCardVersion', foreign_key: 'card_id'

    def time_segments_by_developer(developer)
      time_segments.select { |segment| segment.developed_by?(developer) }
    end

    def initiative
      OveCard.find(cp_initiative_tree___initiative_card_id) unless cp_initiative_tree___initiative_card_id.nil?
    end
  end
end