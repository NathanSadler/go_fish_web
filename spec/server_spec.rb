require 'rack/test'
require 'rspec'
require 'capybara'
require 'capybara/dsl'
ENV['RACK_ENV'] = 'test'
require_relative '../server'

RSpec.describe Server do
  # include Rack::Test::Methods
  include Capybara::DSL
  before do
    Capybara.app = Server.new
  end
  let(:session1) {Capybara::Session.new(:rack_test, Server.new)}
  let(:session2) {Capybara::Session.new(:rack_test, Server.new)}

  before(:each) do
    [session1, session2].each_with_index do |session, index|
      player_name = "Player #{index + 1}"
      session.visit '/'
      session.fill_in :name, with: player_name
      session.click_on 'Join'
    end
  end

  after(:each) do
    Server.game.clear_players
  end

  it 'is possible to join a game' do
    visit '/'
    fill_in :name, with: 'John'
    click_on 'Join'
    expect(page).to have_content('Players')
    expect(page).to have_content('John')
  end

  context 'multiple people joining a game' do

    before(:each) do
      [session1, session2].each_with_index do |session, index|
        player_name = "Player #{index + 1}"
        session.visit '/'
        session.fill_in :name, with: player_name
        session.click_on 'Join'
      end
    end
    it 'displays a list with the name of each player' do
      expect(session2).to have_content('Player 1')
      expect(session2).to have_content('Player 2')
    end
    it 'updates the list when a user refreshes' do
      session1.driver.refresh
      expect(session1).to have_content('Player 1')
      expect(session1).to have_content('Player 2')
    end
    it "displays the user's name in bold text" do
      expect(session1).to have_css('b', text: 'Player 1')
      expect(session2).to have_css('b', text: 'Player 2')
    end
    it "doesn't disply other players' names in bold" do
      expect(session2).to_not have_css('b', text: 'Player 1')
      expect(session1).to_not have_css('b', text: 'Player 2')
    end
  end

  context "players pressing the 'try to take turn button'" do
    it "links players to the take_turn page if it is there turn" do
      session1.click_on "Try to Take Turn"
      expect(session1).to have_content("Take Your Turn")
      session1.click_on "Take Turn"
      session2.click_on "Try to Take Turn"
      expect(session2).to have_content("Take Your Turn")
    end
    it "redirects players to the waiting_room page if it isn't their turn" do
      session1.click_on "Try to Take Turn"
      session1.click_on "Take Turn"
      session1.click_on "Try to Take Turn"
      expect(session1).to_not have_content("Take Your Turn")
    end
    it "always redirects back to waiting_room if there aren't enough players" do
      Server.game.clear_players
      test_session = Capybara::Session.new(:rack_test, Server.new)
      test_session.visit '/'
      test_session.fill_in :name, with: "Test Name"
      test_session.click_on 'Join'
      test_session.click_on "Try to Take Turn"
      expect(test_session).to_not have_content("Take Your Turn")
    end
  end

end
