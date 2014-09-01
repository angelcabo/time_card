describe 'OveCard' do

  before(:context) do
    @object_factory = TestObjectFactory.new
    @attributes = YAML.load_file('spec/fixtures/time_card.yml')
  end

  it 'should have an initiative' do
    initiative_card = TimeCard::OveCard.create! @attributes['initiative']
    feature_card = TimeCard::OveCard.create! @attributes['feature']
    expect(feature_card.initiative.id).to eq(initiative_card.id)
  end

  context :time_segments_by_developer do
    it 'should' do
      pat = TimeCard::Developer.new 'pat'
      card = @object_factory.user_story name: 'Login Feature', status: 'Ready for Development', time: DateTime.parse('2014-08-25 10:00')
      @object_factory.start_development card, dev_pair: 'River/Pat', time: DateTime.parse('2014-08-25 11:00')
      @object_factory.switch_pairs card, dev_pair: 'Phoenix/Pat', time: DateTime.parse('2014-08-26 11:00')
      @object_factory.finish_development card, time: DateTime.parse('2014-08-26 18:00')

      segments = card.time_segments_by_developer(pat)

      expect(segments.size).to eq(2)
    end
  end

  context :to_s do
    it 'should output summary information for the card' do
      initiative_card = TimeCard::OveCard.create! @attributes['initiative']
      feature_card = TimeCard::OveCard.create! @attributes['feature']
      card_without_initiative = TimeCard::OveCard.create! @attributes['feature_without_initiative']

      expect(card_without_initiative.to_s).to eq("#{card_without_initiative.number},#{card_without_initiative.name},#{card_without_initiative.cp_dev_pair},UNKNOWN INITIATIVE,UNKNOWN INITIATIVE")
      expect(feature_card.to_s).to eq("#{feature_card.number},#{feature_card.name},#{feature_card.cp_dev_pair},#{initiative_card.name},#{initiative_card.cp_oracle_code}")
    end
  end
end