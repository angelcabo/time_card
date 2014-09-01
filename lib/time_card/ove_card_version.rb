module TimeCard
  class OveCardVersion < ActiveRecord::Base
    self.table_name = 'ove_2_card_versions'

    def to_s
      "#{cp_status},#{updated_at},#{cp_dev_pair}"
    end
  end
end