module TimeCard
  class Report

    def initialize(options)
      @card_data_file = options[:card_data_file]
      @card_klass = options[:card_klass]
      @start_date = options[:start_date]
      @end_date = options[:end_date]
    end

    def card_work_summary
      return cards_from_summary_file if @card_data_file
      @card_klass.find_all_in_time_range(@start_date, @end_date)
    end

    def cards_from_summary_file
      card_data = JSON.parse(File.read(@card_data_file))
      card_data.map { |card| @card_klass.new card }
    end

    def find_all_initiatives
      initiative_ids = @card_klass.select(:cp_initiative_tree___initiative_card_id).uniq
      @card_klass.where(id: initiative_ids).order('created_at DESC')
    end

    def all_developers(cards)
      devs = []
      cards.each do |card|
        devs.concat card.developers
      end
      devs.uniq
    end

    def work_summary_for_developer(developer, cards)
      initiatives = cards.group_by { |c| c.initiative.cp_oracle_code }
      summary = {}
      initiatives.each do |initiative_id, initiative_cards|
        summary[initiative_id] = initiative_cards.inject(0) do |total_time_for_initiative, card|
          total_time_for_initiative + time_spent_on_card(card, developer)
        end
      end
      summary
    end

    def work_breakdown_for_developers(developers, cards)
      initiatives = cards.group_by { |c| c.initiative.cp_oracle_code }
      summary = []
      initiatives.each do |initiative_id, initiative_cards|
        total_minutes = initiative_cards.inject(0) do |total_time_per_initiative, card|
          developers.inject(total_time_per_initiative) do |total_time_per_dev, dev|
            total_time_per_dev + time_spent_on_card(card, dev)
          end
        end
        summary << {oracle_code: initiative_id, hours: (total_minutes / 60.0).round(2)}
      end
      summary
    end

    def time_spent_on_card(card, developer)
      card_time_segments = card.time_segments_by_developer(developer)
      developer.work_days(@start_date, @end_date).inject(0) do |total_time_on_card, workday|
        card_time_segments.inject(total_time_on_card) do |time_worked_during_day, segment|
          minutes_worked = developer.min_worked_during_segment(workday, segment.start_time, segment.end_time)
          time_worked_during_day + minutes_worked
        end
      end
    end
  end
end