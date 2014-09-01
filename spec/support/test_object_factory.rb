class TestObjectFactory
  def initialize
    @user_story_attributes = YAML.load_file('spec/fixtures/user_story.yml')
    @card_numbers = (1..100).to_a
  end

  def create_card_version(card, attributes)
    card.versions.create! attributes
  end

  def create_card(attributes)
    TimeCard::OveCard.create!(attributes)
  end

  def create_initiative(options)
    initiative_attributes = {
        number: next_card_number,
        name: options[:name],
        cp_oracle_code: options[:code]
    }
    create_card(@user_story_attributes['initiative'].merge(initiative_attributes))
  end

  def user_story(options)
    card_attributes = {
        name: options[:name],
        version: 1,
        number: next_card_number,
        cp_status: options[:status],
        cp_dev_pair: options[:dev_pair],
        cp_initiative_tree___initiative_card_id: options[:initiative_id]}
    card_version_attributes = {
        cp_status: options[:status],
        cp_dev_pair: options[:dev_pair],
        updated_at: options[:time]}
    card = create_card(@user_story_attributes['card'].merge(card_attributes))
    create_card_version(card, @user_story_attributes['version'].merge(card_version_attributes))
    card
  end

  def next_card_number
    @card_numbers.delete(@card_numbers.first)
  end

  def start_development(card, options)
    card_version_attributes = {cp_status: 'In Development',
                               cp_dev_pair: options[:dev_pair],
                               updated_at: options[:time]}
    card.update_attribute :version, card.version + 1
    create_card_version(card, @user_story_attributes['version'].merge(card_version_attributes))
    card
  end

  def switch_pairs(card, options)
    card_version_attributes = {cp_status: 'In Development',
                               cp_dev_pair: options[:dev_pair],
                               updated_at: options[:time]}
    card.update_attribute :version, card.version + 1
    create_card_version(card, @user_story_attributes['version'].merge(card_version_attributes))
    card
  end

  def finish_development(card, options)
    card_version_attributes = {cp_status: 'Ready for Test',
                               cp_dev_pair: options[:dev_pair],
                               updated_at: options[:time]}
    card.update_attribute :version, card.version + 1
    create_card_version(card, @user_story_attributes['version'].merge(card_version_attributes))
    card
  end
end