module TimeCard
  class Developer
    attr_accessor :name

    def initialize(name, schedule = nil)
      default_schedule = {
          1 => OpenStruct.new(start_time: '08:00', end_time: '19:30'),
          2 => OpenStruct.new(start_time: '08:00', end_time: '19:30'),
          3 => OpenStruct.new(start_time: '08:00', end_time: '19:30'),
          4 => OpenStruct.new(start_time: '08:00', end_time: '19:30'),
          5 => OpenStruct.new(start_time: '08:00', end_time: '19:30')
      }
      @schedule = schedule || default_schedule
      @name = name
    end

    def work_days(start_date, end_date)
      days_worked = []
      (start_date..end_date).each do |day|
        workday = schedule_on_day(day)
        days_worked.push workday unless workday.nil?
      end
      days_worked
    end

    def schedule_on_day(day)
      if @schedule[day.wday]
        schedule_start_time = Time.parse("#{day.to_date} #{@schedule[day.wday].start_time}")
        schedule_end_time = Time.parse("#{day.to_date} #{@schedule[day.wday].end_time}")
        OpenStruct.new(start_time: schedule_start_time, end_time: schedule_end_time)
      end
    end

    def min_worked_during_segment(workday, start_time, end_time = nil)
      end_time ||= workday.end_time
      time_worked = 0
      unless start_time > workday.end_time || end_time < workday.start_time || start_time > end_time
        start_work = [workday.start_time, start_time].max
        end_work = [workday.end_time, end_time].min
        time_worked = end_work - start_work
      end
      (time_worked/60.0).to_i
    end
  end
end