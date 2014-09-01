describe 'Developer' do

  before(:context) do
    @schedule = {
        1 => OpenStruct.new(start_time: '10:00', end_time: '18:00'),
        3 => OpenStruct.new(start_time: '10:00', end_time: '18:00'),
        5 => OpenStruct.new(start_time: '10:00', end_time: '18:00')
    }
    @monday = Date.parse('2014-08-25')
    @friday = Date.parse('2014-08-29')
    @monday_at_8_am = Time.parse('2014-08-25 08:00')
    @monday_at_10_am = Time.parse('2014-08-25 10:00')
    @monday_at_6_pm = Time.parse('2014-08-25 18:00')
    @monday_at_7_30_pm = Time.parse('2014-08-25 19:30')
    @monday_at_8_pm = Time.parse('2014-08-25 20:00')
  end

  it 'should default with a schedule' do
    developer = TimeCard::Developer.new 'phoenix'
    expect(developer.schedule_on_day(@monday).start_time).to eq(@monday_at_8_am)
    expect(developer.schedule_on_day(@monday).end_time).to eq(@monday_at_7_30_pm)
  end

  it 'should accept a schedule to use' do
    developer = TimeCard::Developer.new 'phoenix', @schedule
    expect(developer.schedule_on_day(@monday).start_time).to eq(@monday_at_10_am)
    expect(developer.schedule_on_day(@monday).end_time).to eq(@monday_at_6_pm)
  end

  context :work_days do

    it 'should return a list of days based on work schedule when given a time range' do
      developer = TimeCard::Developer.new 'phoenix', @schedule
      expect(developer.work_days(@monday, @friday).size).to eq(3)
    end
  end

  context :minutes_worked_during_time_segment do

    it 'should return the minutes worked given a day and a time segment start/end' do
      developer = TimeCard::Developer.new 'phoenix', @schedule
      segment = TimeCard::TimeSegment.new TimeCard::OveCardVersion.new(cp_status: 'In Development', cp_dev_pair: 'phoenix/river', updated_at: @monday_at_10_am)
      segment.end_time = @monday_at_6_pm
      expect(developer.min_worked_during_segment(developer.schedule_on_day(@monday), segment.start_time, segment.end_time)).to eq(480) # 8 hours
    end

    it 'should use workday end time if segment end time is nil' do
      developer = TimeCard::Developer.new 'phoenix', @schedule
      segment = TimeCard::TimeSegment.new TimeCard::OveCardVersion.new(cp_status: 'In Development', cp_dev_pair: 'phoenix/river', updated_at: @monday_at_10_am)
      expect(developer.min_worked_during_segment(developer.schedule_on_day(@monday), segment.start_time, segment.end_time)).to eq(480) # 8 hours
    end

    it 'should return 0 if segment start time is after the work day end time' do
      developer = TimeCard::Developer.new 'phoenix', @schedule
      segment = TimeCard::TimeSegment.new TimeCard::OveCardVersion.new(cp_status: 'In Development', cp_dev_pair: 'phoenix/river', updated_at: @monday_at_8_pm)
      expect(developer.min_worked_during_segment(developer.schedule_on_day(@monday), segment.start_time, segment.end_time)).to eq(0)
    end

    it 'should return 0 if the segment ended before the work day start time' do
      developer = TimeCard::Developer.new 'phoenix', @schedule
      segment = TimeCard::TimeSegment.new TimeCard::OveCardVersion.new(cp_status: 'In Development', cp_dev_pair: 'phoenix/river', updated_at: @monday_at_8_am)
      segment.end_time = @monday_at_8_am
      expect(developer.min_worked_during_segment(developer.schedule_on_day(@monday), segment.start_time, segment.end_time)).to eq(0)
    end

    it 'should return 0 if the segment end time is after the segment start time' do
      developer = TimeCard::Developer.new 'phoenix', @schedule
      segment = TimeCard::TimeSegment.new TimeCard::OveCardVersion.new(cp_status: 'In Development', cp_dev_pair: 'phoenix/river', updated_at: @monday_at_10_am)
      segment.end_time = @monday_at_8_am
      expect(developer.min_worked_during_segment(developer.schedule_on_day(@monday), segment.start_time, segment.end_time)).to eq(0)
    end
  end
end