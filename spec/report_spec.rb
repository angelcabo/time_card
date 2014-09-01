describe 'Report' do

  # noinspection RailsParamDefResolve
  before(:context) do
    @object_factory = TestObjectFactory.new
  end

  context :time_spent_on_card do
    it 'should do something' do
      schedule = {
          1 => OpenStruct.new(start_time: '08:00', end_time: '18:00'),
          2 => OpenStruct.new(start_time: '08:00', end_time: '18:00'),
          3 => OpenStruct.new(start_time: '08:00', end_time: '18:00'),
          4 => OpenStruct.new(start_time: '08:00', end_time: '18:00'),
          5 => OpenStruct.new(start_time: '08:00', end_time: '18:00')
      }
      river = TimeCard::Developer.new 'river', schedule
      card = @object_factory.user_story name: 'Login Feature', status: 'Ready for Development', time: DateTime.parse('2014-08-25 10:00')
      @object_factory.start_development card, dev_pair: 'River/Pat', time: DateTime.parse('2014-08-25 11:00')
      @object_factory.switch_pairs card, dev_pair: 'Phoenix/Pat', time: DateTime.parse('2014-08-26 11:00')
      report = TimeCard::Report.new card_klass: TimeCard::OveCard, start_date: Date.parse('2014-08-24'), end_date: Date.parse('2014-08-28')

      minutes_worked = report.time_spent_on_card(card, river)

      expect(minutes_worked).to eq(600)
    end
  end

  context :work_summary_for_developer do

    # noinspection RailsParamDefResolve
    before(:context) do
      @start_date = Date.today - 5
      @end_date = Date.today
    end

    it 'should return a list of initiatives with hours worked for each' do
      schedule = {
          1 => OpenStruct.new(start_time: '08:00', end_time: '18:00'),
          2 => OpenStruct.new(start_time: '08:00', end_time: '18:00'),
          3 => OpenStruct.new(start_time: '08:00', end_time: '18:00'),
          4 => OpenStruct.new(start_time: '08:00', end_time: '18:00'),
          5 => OpenStruct.new(start_time: '08:00', end_time: '18:00')
      }
      river = TimeCard::Developer.new 'river', schedule
      login_initiative = @object_factory.create_initiative name: 'Login Initiative'
      login_story = @object_factory.user_story name: 'Login Feature', initiative_id: login_initiative.id, status: 'Ready for Development', time: DateTime.parse('2014-08-25 07:00')
      @object_factory.start_development login_story, dev_pair: 'River/Pat', time: DateTime.parse('2014-08-25 08:00')
      @object_factory.finish_development login_story, time: DateTime.parse('2014-08-27 08:00') # Finished after 20 work hours based on schedule
      report = TimeCard::Report.new card_klass: TimeCard::OveCard, start_date: Date.parse('2014-08-24'), end_date: Date.parse('2014-08-28')

      cards = report.card_work_summary
      initiative_breakdown = report.work_summary_for_developer(river, cards)

      expect(initiative_breakdown[login_initiative.cp_oracle_code]).to eq(1200)
    end

  end

  context :work_breakdown_for_time_range do

    # noinspection RailsParamDefResolve
    before(:context) do
      @sunday = Date.parse('2014-08-24')
      @saturday = Date.parse('2014-08-30')
      @monday_at_10_am = Time.parse('2014-08-25 10:00')
      @monday_at_11_am = Time.parse('2014-08-25 11:00')
      @monday_at_6_pm = Time.parse('2014-08-25 18:00')
      @tuesday_at_11_am = Time.parse('2014-08-26 11:00')
      @wednesday_at_11_am = Time.parse('2014-08-27 11:00')
    end

    it 'should return a list of initiatives with hours worked for each' do
      schedule_a = {
          1 => OpenStruct.new(start_time: '11:00', end_time: '19:00'),
          2 => OpenStruct.new(start_time: '11:00', end_time: '19:00'),
          3 => OpenStruct.new(start_time: '11:00', end_time: '19:00'),
          4 => OpenStruct.new(start_time: '11:00', end_time: '19:00'),
          5 => OpenStruct.new(start_time: '11:00', end_time: '19:00')
      }
      river = TimeCard::Developer.new 'river', schedule_a
      phoenix = TimeCard::Developer.new 'phoenix', schedule_a
      schedule_b = {
          1 => OpenStruct.new(start_time: '08:00', end_time: '16:00'),
          2 => OpenStruct.new(start_time: '08:00', end_time: '16:00'),
          3 => OpenStruct.new(start_time: '08:00', end_time: '16:00'),
          4 => OpenStruct.new(start_time: '08:00', end_time: '16:00'),
          5 => OpenStruct.new(start_time: '08:00', end_time: '16:00')
      }
      lyric = TimeCard::Developer.new 'lyric', schedule_b
      pat = TimeCard::Developer.new 'pat', schedule_b
      login_initiative = @object_factory.create_initiative name: 'Login Initiative', code: '123'
      search_initiative = @object_factory.create_initiative name: 'Search Initiative', code: '456'
      login_story = @object_factory.user_story name: 'Login Feature', initiative_id: login_initiative.id, status: 'Ready for Development', dev_pair: nil, time: @monday_at_10_am
      search_story = @object_factory.user_story name: 'Search Feature', initiative_id: search_initiative.id, status: 'Ready for Development', dev_pair: nil, time: @monday_at_10_am

      # Work Summary
      @object_factory.start_development login_story, dev_pair: 'River/Pat', time: @monday_at_11_am
      @object_factory.switch_pairs login_story, dev_pair: 'River/Phoenix', time: @tuesday_at_11_am
      @object_factory.finish_development login_story, time: @wednesday_at_11_am  # River: 16 hours, Phoenix: 8 hours, Pat: 8 hours
      @object_factory.start_development search_story, dev_pair: 'Lyric/Phoenix', time: @monday_at_11_am
      @object_factory.finish_development search_story, time: @monday_at_6_pm # Lyric: 5 hours, Phoenix: 7 hours

      report = TimeCard::Report.new card_klass: TimeCard::OveCard, start_date: @sunday, end_date: @saturday
      cards = report.card_work_summary
      initiative_breakdown = report.work_breakdown_for_developers [river, phoenix, lyric, pat], cards
      expect(initiative_breakdown.find {|i| i[:oracle_code] == login_initiative.cp_oracle_code}[:hours]).to eq(32.0)
      expect(initiative_breakdown.find {|i| i[:oracle_code] == search_initiative.cp_oracle_code}[:hours]).to eq(12.0)
    end

  end

  context :card_work_summary do

    # noinspection RailsParamDefResolve
    before(:context) do
      @start_date = Date.today - 1
      @end_date = Date.today + 1
    end

    it 'should have a summary of cards for a given time range' do
      user_story = @object_factory.user_story name: 'Login Feature', status: 'In Development', time: Date.today
      report = TimeCard::Report.new card_klass: TimeCard::OveCard, start_date: @start_date, end_date: @end_date

      summary = report.card_work_summary

      expect(summary.size).to eq(1)
      expect(summary[0].id).to eq(user_story.id)
    end

    it 'when given a file: should return cards using data from the specified file' do
      report = TimeCard::Report.new card_klass: TimeCard::OveCard,
                                    card_data_file: 'spec/fixtures/card_work_summary_fixture.json',
                                    start_date: @start_date,
                                    end_date: @end_date

      cards = report.card_work_summary

      expect(cards.size).to eq(1)
      expect(cards[0].id).to eq(190197)
    end

  end

  context :all_developers do

    # noinspection RailsParamDefResolve
    before(:context) do
      @start_date = Date.today - 1
      @end_date = Date.today + 1
    end

    it 'should return all developers who worked on cards during the given time range' do
      @object_factory.user_story name: 'Story 1', status: 'Ready for Test', dev_pair: 'River/Pat', time: Date.today
      @object_factory.user_story name: 'Story 2', status: 'In Development', dev_pair: 'Phoenix/Oakley', time: Date.today
      @object_factory.user_story name: 'Story 3', status: 'In Development', dev_pair: 'Lyric/Riley', time: Date.today
      report = TimeCard::Report.new card_klass: TimeCard::OveCard, start_date: @start_date, end_date: @end_date

      cards = report.card_work_summary
      devs = report.all_developers cards

      expect(devs.size).to eq(4)
      # noinspection RubyResolve
      expect(devs).not_to include('pat')
    end

    it 'should not return duplicate names' do
      @object_factory.user_story name: 'Login Feature', status: 'In Development', dev_pair: 'Phoenix/Oakley', time: Date.today
      @object_factory.user_story name: 'Search Feature', status: 'In Development', dev_pair: 'River/Oakley', time: Date.today
      report = TimeCard::Report.new card_klass: TimeCard::OveCard, start_date: @start_date, end_date: @end_date
      cards = report.card_work_summary
      devs = report.all_developers(cards)

      expect(devs.size).to eq(3)
      expect(devs.find_all{|d| d == 'oakley'}.size).to eq(1)
    end

    it 'should not throw an error if a dev pair is not specified' do
      @object_factory.user_story name: 'Login Feature', status: 'In Development', dev_pair: nil, time: Date.today
      report = TimeCard::Report.new card_klass: TimeCard::OveCard, start_date: @start_date, end_date: @end_date
      cards = report.card_work_summary
      expect { report.all_developers(cards) }.not_to raise_error
    end

  end
end