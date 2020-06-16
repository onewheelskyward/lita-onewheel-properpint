require 'spec_helper'

describe Lita::Handlers::OnewheelBeerProperPint, lita_handler: true do
  it { is_expected.to route_command('proper') }
  it { is_expected.to route_command('proper 4') }

  before do
    mock = File.open('spec/fixtures/properpint.html').read
    allow(RestClient).to receive(:get) { mock }
  end

  it 'shows the taps' do
    send_command 'proper'
    expect(replies.last).to eq("Proper's taps: 1) Sticky Hands IIPA Block 15  2) Montavilla Lil' More Righteous ISA  3) Helles Lager Rosenstadt  4) Topcutter IPA Bale Breaker  5) Leafwalker Red Bent Shovel  6) 54-40 Belgium Quad Avant Garde A Clue  7) Old Town Glow Torch  8) Forgeberry Tart Ale Ale Smith  9) Wanderlust IPA Breakside  10) Empire of the Clouds NEIPA Grains of Wrath  11) Oatis Stout Ninkasi  12) Upright Three Deadly Hops Amber   13) Bone Dry Cuvee Cider Swift  14) Pipp Crush Cider  15) Grapefruit Hibiscus Beet BoochCraft Hard Kombucha  16) Underberg")
  end

  it 'displays details for tap 4' do
    send_command 'taps 4'
    expect(replies.last).to eq('Proper\'s tap 4) Wild Ride Solidarity - Abbey Dubbel – Barrel Aged (Pinot Noir) 8.2%, 4oz - $4 | 12oz - $7, 26% remaining')
  end

  it 'doesn\'t explode on 1' do
    send_command 'proper 1'
    expect(replies.count).to eq(1)
    expect(replies.last).to eq('Proper\'s tap 1) Cider Riot! Plastic Paddy - Apple Cider w/ Irish tea 6.0%, 10oz - $4 | 20oz - $7 | 32oz Crowler - $10, 48% remaining')
  end
end
