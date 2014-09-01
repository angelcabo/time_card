class Stub < OpenStruct
  include TimeCard::DevPairParsing
end

describe 'DevPairParsing' do

  it 'should parse a dev pair string into a list of developer names' do
    devs = Stub.new(cp_dev_pair: 'lyric/phoenix').developers
    expect(devs.size).to eq(2)
    expect(devs).to include('lyric')
    expect(devs).to include('phoenix')
  end
end