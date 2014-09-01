module TimeCard
  module QueryableOnMingle

    def find_all_in_time_range(start_time, end_time)
      # There are 2 cases captured by the UNION:
      # Case 1: The card was in development at the start of the time period. In
      #   this case we find the latest version row that happened before the
      #   start time and see if the status is In development.
      # Case 2: The card moved to In development during the time period.
      find_by_sql <<-END_SQL
         SELECT *
         FROM #{table_name}
         WHERE id IN
          (SELECT version.card_id FROM ove_2_card_versions version JOIN
            (SELECT card_id, MAX(version) AS max_version
             FROM ove_2_card_versions
             WHERE updated_at < '#{start_time}'
             GROUP BY card_id) latest_version ON version.card_id = latest_version.card_id AND version.version = latest_version.max_version
            WHERE LOWER(version.cp_status) = 'in development')
         UNION
         SELECT *
         FROM #{table_name} card
         WHERE EXISTS (SELECT 1
                       FROM ove_2_card_versions version
                       WHERE LOWER(version.cp_status) = 'in development' AND card_id = card.id AND updated_at BETWEEN '#{start_time}' AND '#{end_time}')
      END_SQL
    end
  end
end