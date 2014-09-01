describe 'TimeSegment' do

  context :developed_by? do

    # noinspection RailsParamDefResolve
    before(:context) do
      @river = TimeCard::Developer.new 'river'
      @lyric = TimeCard::Developer.new 'lyric'
      @phoenix = TimeCard::Developer.new 'phoenix'
    end

    it 'should return true if the segment dev pair includes the given developer' do
      segment = TimeCard::TimeSegment.new TimeCard::OveCardVersion.new(cp_status: 'In Development', cp_dev_pair: 'phoenix/river')
      expect(segment.developed_by?(@river)).to be_truthy
      expect(segment.developed_by?(@phoenix)).to be_truthy
    end

    it 'should return false if the segment dev pair does not include the given developer' do
      segment = TimeCard::TimeSegment.new TimeCard::OveCardVersion.new(cp_status: 'In Development', cp_dev_pair: 'phoenix/river')
      expect(segment.developed_by?(@lyric)).to be_falsey
    end

    it 'should return false if the segment status is not "In Development"' do
      segment = TimeCard::TimeSegment.new TimeCard::OveCardVersion.new(cp_status: 'Ready for Test', cp_dev_pair: 'phoenix/river')
      expect(segment.developed_by?(@river)).to be_falsey
    end

    it 'should return false if the segment status is nil' do
      segment = TimeCard::TimeSegment.new TimeCard::OveCardVersion.new(cp_status: nil, cp_dev_pair: 'phoenix/river')
      expect(segment.developed_by?(@river)).to be_falsey
    end
  end

end