require 'spec_helper'

describe Lita::Handlers::OnewheelBeerProperPint, lita_handler: true do
  it { is_expected.to route_command('proper') }
  it { is_expected.to route_command('proper 4') }

  before do
    mock = File.open('spec/fixtures/properpint-dinein.html').read
    allow(RestClient).to receive(:get) { mock }
  end

  it 'shows the taps' do
    send_command 'proper'
    expect(replies.last).to include("Proper's taps: 1) RPM IPA Boneyard  2) Sneaky Deer Double NEIPA Spider City  3) Preservation Sour Urban Family Brewing  4) Frost Hammer Helles Grains of Wrath  5) Juicy Gorilla Snax IPA WildRide  6) Coconut Porter Maui  7) The Wood Lager Laurelwood  8) Free Range Red Ale Laurelwood  9) Get Up, Stand Up NEIPA Ex Novo  10) 2020 Peche Sour pFriem  11) Brother Thelonious Strong Dark North Coast  12) Window Shopper IPA West Coast Grocery  13) Oatis Stout Ninkasi  14) Dad Beer Lager Baerlic  15) Crimea  a River BBA Stout Oregon City Brewing  16) Orchard Dry Cider Long Drop  17) '18 Kriek Sour Cherry Baird & Dewar  18) Sangria Cider Portland Cider Company  19) Clyde's Dry Cider Baumans  20) Underberg   Order now at https://my-site-109373-104980.square.site/")
  end

  it 'displays details for tap 4' do
    send_command 'proper 4'
    expect(replies.last).to include("Proper's tap 4) Frost Hammer Helles Grains of Wrath")
  end

  it 'doesn\'t explode on 1' do
    send_command 'proper 1'
    expect(replies.count).to eq(1)
    expect(replies.last).to include("Proper's tap 1) RPM IPA Boneyard")
  end
end
