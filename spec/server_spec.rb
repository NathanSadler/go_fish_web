require 'rack/test'
require 'rspec'
require 'capybara'
require 'capybara/dsl'
require 'selenium/webdriver'
require 'webdrivers/chromedriver'
ENV['RACK_ENV'] = 'test'
require_relative '../server'
require_relative '../lib/card'
require_relative '../lib/player'

# Selects a card and player from take_turn.slim and clicks the Take Turn button.
def take_turn(session, card, player)
  session.choose(card)
  session.choose(player)
  session.click_on("Take Turn")
end

def create_game(session, min_players, max_players, max_bots)
  session.visit('/create_game')
  fill_in_game_form(session, min_players, max_players, max_bots)
  session.click_on("Create Game")
end

def fill_in_game_form(session, min_players, max_players, max_bots)
  session.select(min_players.to_s, from: 'Minimum Players')
  session.select(max_players.to_s, from: 'Maximum Players')
  session.select(max_bots.to_s, from: "Maximum Bots")
end

RSpec.describe Server do
  # include Rack::Test::Methods
  include Capybara::DSL
  before(:all) do
    Capybara.app = Server.new
    Capybara.server = :webrick
  end
  let(:session1) {Capybara::Session.new(:rack_test, Server.new)}
  let(:session2) {Capybara::Session.new(:rack_test, Server.new)}

  before(:each) do
    [session1, session2].each_with_index do |session, index|
      session.visit '/'
      session.fill_in :name, with: "Player #{index + 1}"
      session.click_on 'Join'
    end
    session1.click_on 'Proceed to Game'
    session2.click_on 'Proceed to Game'
  end

  after(:each) do
    Player.clear_players
    Server.reset_game
  end

  context('.set_game_created') do
    it("sets the value of the game_created class variable") do
      Server.set_game(true)
      expect(Server.game_created?)
    end
  end

  context('creating a game') do
    let (:test_session) {Capybara::Session.new(:rack_test, Server.new)}

    before(:each) do
      Server.reset_game
      test_session.visit '/create_game'
    end

    it("lets users create a game with a specific number of players and bots") do
      create_game(test_session, "3", "3", "0")
      current_game = Server.game
      expect(current_game.min_players).to(eq(3))
      expect(current_game.max_players).to(eq(3))
    end

    it("directs players away from the page if a game has been created") do
      create_game(test_session, "3", "3", "0")
      test_session.visit('/create_game')
      expect(test_session.current_path).to(eq("/wait_to_start"))
    end
  end

  context('user enters their name and waits for the game to start') do
    it("takes the user to a waiting page") do
      test_session = Capybara::Session.new(:rack_test, Server.new)
      test_session.visit '/'
      test_session.fill_in :name, with: "Test Player"
      test_session.click_on 'Join'
      expect(test_session).to have_content("Wait For Other Players")
    end
  end

  context("A user clicks the 'proceed to game' button") do
    it("deals cards to all players in the game") do
      [0,1].each { |player_number| expect(Server.game.players[player_number].hand.empty?).to(eq(false))}
    end

    it("shuffles the deck before dealing cards") do
      dummy_deck = Deck.new
      14.times {dummy_deck.draw_card}
      expect(Server.game.deck.cards).to_not(eq(dummy_deck.cards))
    end

    it("doesn't deal cards for the same game multiple times") do
      expect(Server.game.deck.cards.length).to(eq(38))
    end

    it("redirects to itself and doesn't do anything else if there are fewer "+
    "than the minimum number of players in the game") do
      Server.reset_game
      test_session = Capybara::Session.new(:rack_test, Server.new)
      test_session.visit '/'
      test_session.fill_in :name, with: "Test Player"
      test_session.click_on 'Join'
      test_session.click_on 'Proceed to Game'
      expect(test_session).to have_content("Wait For Other Players")
    end
  end

  context("displaying turn info on the waiting_room page") do
    before(:each) do
      Server.reset_game
      Player.clear_players
    end

    let(:game) {Server.game}
    let(:game_result_header) {"Game Over"}
    let(:session1) {Capybara::Session.new(:selenium_chrome_headless, Server.new)}
    let(:session2) {Capybara::Session.new(:selenium_chrome_headless, Server.new)}

    before(:each) do
      [session1, session2].each_with_index do |session, index|
        session.visit '/'
        session.fill_in :name, with: "Player #{index + 1}"
        session.click_on 'Join'
      end
      [session1, session2].each {|session| session.click_on 'Proceed to Game'}
    end

    before(:each) do
      game.players[0].set_hand([Card.new("3", "C"), Card.new("3", "D"),
        Card.new("3", "H"), Card.new("4", "D"), Card.new("9", "S")])
      game.players[1].set_hand([Card.new("3", "S"), Card.new("4", "C"), Card.new("7", "H")])
      game.deck.send(:set_cards, [Card.new("8", "S"), Card.new("10", "D")])
      session1.click_on("Try to Take Turn")
    end

    it("displays the results of each turn as they happen", :js) do
      expect(session2).to_not(have_content("Player 1 asked for 4(s) and took 1 4(s) from Player 2"))
      take_turn(session1, "4 of Diamonds", "1")
      session1.click_on("Ok")
      expect(session2).to(have_content("Player 1 asked for 4s and took 1 4(s) from Player 2"))
    end

    it("displays the results in order", :js) do
      take_turn(session1, "4 of Diamonds", "1")
      session1.click_on("Ok")
      take_turn(session1, "9 of Spades", "1")
      session1.click_on("Ok")
      expect(session2.all('.round-result')[0].text).to(eq("Player 1 asked for 9s and took 1 card(s) from the deck"))
      expect(session2.all('.round-result')[1].text).to(eq("Player 1 asked for 4s and took 1 4(s) from Player 2"))
    end
  end

  context("the take_turn page") do
    before(:each) do
      Server.game.players[0].set_hand([Card.new("2", "D"), Card.new("3", "D"), Card.new("K", "S")])
      Server.game.players[1].set_hand([Card.new("3", "S")])
      session1.click_on "Try to Take Turn"
    end

    # TODO: inspect how it seems to just fail for fun sometimes
    it("displays the cards in the player's hand") do
      expect(session1).to have_content("2 of Diamonds")
      take_turn(session1, "2 of Diamonds", "1")
      session1.click_on("Ok")
      session2.click_on "Try to Take Turn"
      expect(session2).to(have_content("3 of Spades"))
    end

    it("doesn't display more cards than the user has") do
      expect(session1.assert_selector('[name=card]', count: 3)).to(eq(true))
    end

    it("doesn't display list more players than there actually are") do
      expect(session1.assert_selector('[name=player_id]', count: 1)).to(eq(true))
    end

    it("displays new cards in the player's hand if they got any since last "+
    "time they were on the page") do
      take_turn(session1, "3 of Diamonds", "1")
      session1.click_on("Ok")
      expect(session1).to(have_content("3 of Spades"))
    end

    it("lets users select a card") do
      expect {session1.choose("2 of Diamonds")}.to_not raise_error
    end

    it("doesn't display cards not in the player's hand") do
      expect(session1).to_not have_content("3 of Spades")
    end

    it("displays the other players") do
      expect(session1).to have_content("Player 2")
    end

    it("does not display the player using the page") do
      expect(session1).to_not have_content("Player 1")
    end

    xit("displays information about the previous turn") do
      take_turn(session1, "2 of Diamonds", "1")
      session1.click_on("Ok")
      session2.click_on("Try to Take Turn")
      expect(session2).to(have_content("Player 1 asked Player 2 for a 2 of Diamonds"))
    end
  end

  context 'take_turn page displaying results of each turn' do
    let(:session1) {Capybara::Session.new(:selenium_chrome_headless, Server.new)}
    let(:session2) {Capybara::Session.new(:selenium_chrome, Server.new)}

    before(:each, :js) do
      [session1, session2].each_with_index do |session, index|
        session.visit '/'
        session.fill_in :name, with: "Player #{index + 1}"
        session.click_on 'Join'
      end
      [session1, session2].each {|session| session.click_on 'Proceed to Game'}
    end

    let(:player1) {Server.game.players[0]}

    xit("displays turn results as they happen") do
      Server.game.players[0].set_hand([Card.new("2", "D"), Card.new("3", "D"), Card.new("K", "S")])
      Server.game.players[1].set_hand([Card.new("3", "S"), Card.new("4", "S")])
      session1.click_on "Try to Take Turn"
      expect(session1).to(have_content("3 of Diamonds"))
      take_turn(session1, "3 of Diamonds", "1")
      expect(session2).to(have_content("Player 1 took 1 3(s) from Player 2"))
    end
  end

  context 'asking for cards from another player' do
    before(:each) do
      Server.game.players[0].set_hand([Card.new("2", "D"), Card.new("3", "D"), Card.new("K", "S")])
      Server.game.players[1].set_hand([Card.new("3", "S"), Card.new("K", "D"), Card.new("K", "H")])
      Server.game.deck.send(:set_cards, [Card.new("7", "H")])
      session1.click_on "Try to Take Turn"
      session1.choose("1")
    end

    let(:player1) {Server.game.players[0]}
    let(:player2) {Server.game.players[1]}

    it("doesn't change the displayed suit of cards a player gets from another player") do
      take_turn(session1, "3 of Diamonds", "1")
      session1.click_on("Ok")
      expect(session1.assert_selector("input[id='3-S']", count: 1)).to(eq(true))
      expect(session1.assert_selector("input[id='3-D']", count: 1)).to(eq(true))
    end

    it("doesn't change the suit of cards recieved from another player") do
      player1 = Server.game.players[0]
      take_turn(session1, "King of Spades", "1")
      session1.click_on("Ok")
      rank_three_cards = player1.hand.select {|card| card.rank == "K"}
      rank_three_suits = rank_three_cards.map(&:suit)
      expect(rank_three_suits.sort).to(eq(["D", "H", "S"]))
    end

    it("doesn't alter any of the player's previous cards after getting one " +
      "from the deck") do
      take_turn(session1, "2 of Diamonds", "1")
      session1.click_on("Ok")
      player1.hand.sort_by!(&:rank)
      expected_cards = [Card.new("2", "D"), Card.new("3", "D"), Card.new("7", "H"),
      Card.new("K", "S")]
      expect(player1.hand).to(eq(expected_cards))
    end

    it("allows users to ask for/get a card from another player") do
      take_turn(session1, "3 of Diamonds", "1")
      session1.click_on "Ok"
      expect(session1).to have_content("3 of Spades")
      expect(Server.game.players[0].has_card?(Card.new("3", "S"))).to(eq(true))
      expect(Server.game.players[1].has_card?(Card.new("3", "S"))).to(eq(false))
    end

    it("directs players to a turn_result page") do
      take_turn(session1, "3 of Diamonds", "1")
      expect(session1).to(have_content("Turn Results"))
    end

    it("has the user draw from the deck if the player they ask don't have "+
    "cards of the specified rank") do
      session1.choose("2 of Diamonds")
      session1.click_on("Take Turn")
      expect(Server.game.players[0].has_card?(Card.new("7", "H"))).to(eq(true))
    end

    it("lets the user go again if the other player has a card of the rank they "+
    "want") do
      take_turn(session1, "3 of Diamonds", "1")
      session1.click_on("Ok")
      expect(session1).to(have_content("Take Your Turn"))
    end

    it("doesn't let the user go again if the other player doesn't have a card "+
    "of the rank they ask for") do
      session1.choose("2 of Diamonds")
      session1.click_on("Take Turn")
      session1.click_on("Ok")
      expect(session1).to(have_content("Try to Take Turn"))
    end

    it("does not increment_turn_counter if the player makes a correct guess") do
      take_turn(session1, "3 of Diamonds", "1")
      expect(Server.game.turn_player).to(eq(Server.game.players[0]))
    end

    it("increments turn_counter if the player makes an incorrect guess") do
      take_turn(session1, "2 of Diamonds", "1")
      expect(Server.game.turn_player).to(eq(Server.game.players[1]))
    end
  end

  context 'turn results page' do
    before(:each) do
      Server.game.players[0].set_hand([Card.new("2", "D"), Card.new("3", "D"), Card.new("K", "C"), Card.new("K", "S")])
      Server.game.players[1].set_hand([Card.new("3", "S"), Card.new("K", "D"), Card.new("K", "H")])
      Server.game.deck.send(:set_cards, [Card.new("Q", "H")])
      session1.click_on("Try to Take Turn")
    end

    it 'has a button that takes user back to waiting page' do
      take_turn(session1, "2 of Diamonds", "1")
      session1.click_on("Ok")
      expect(session1).to(have_content("Try to Take Turn"))
    end

    it ('has a button that takes the user back to the take_turn page, when '+
    'needed') do
      take_turn(session1, "3 of Diamonds", "1")
      session1.click_on("Ok")
      expect(session1).to(have_content("Take Your Turn"))
    end

    it ("displays a message about what card(s) the player took from another") do
      take_turn(session1, "3 of Diamonds", "1")
      expect(session1).to(have_content("You took 1 3(s) from Player 2"))
    end
  end

  context 'multiple people joining a game' do
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

  context "game results page" do
    before(:each) do
      Server.reset_game
      Player.clear_players
    end

    let(:game) {Server.game}
    let(:game_result_header) {"Game Over"}
    let(:session1) {Capybara::Session.new(:selenium_chrome_headless, Server.new)}
    let(:session2) {Capybara::Session.new(:selenium_chrome_headless, Server.new)}

    before(:each) do
      [session1, session2].each_with_index do |session, index|
        session.visit '/'
        session.fill_in :name, with: "Player #{index + 1}"
        session.click_on 'Join'
      end
      [session1, session2].each {|session| session.click_on 'Proceed to Game'}
    end

    before(:each) do
      game.increment_turn_counter
      game.players[0].set_hand([Card.new("3", "C"), Card.new("3", "D"),
        Card.new("3", "H")])
      game.players[1].set_hand([Card.new("3", "S")])
      game.deck.send(:set_cards, [])
      session2.click_on("Try to Take Turn")
    end

    it("lists the players in the order they placed in") do
      take_turn(session2, "3 of Spades", "0")
      session2.click_on("Ok")
      [session1, session2].each do |session|
        expect(session).to(have_css('.game-result-player:first-child', text: "Player 2"))
        expect(session).to(have_css('.game-result-player:nth-child(2)', text: "Player 1"))
      end
    end

    it("lists each player's score") do
      take_turn(session2, "3 of Spades", "0")
      session2.click_on("Ok")
      [session1, session2].each do |session|
        expect(session).to(have_css('.game-result-player:first-child', text: "1 book(s)"))
        expect(session).to(have_css('.game-result-player:nth-child(2)', text: "0 book(s)"))
      end
    end

  end

  context "game ending" do
    before(:each) do
      Server.reset_game
      Player.clear_players
    end

    let(:game) {Server.game}
    let(:game_result_header) {"Game Over"}
    let(:session1) {Capybara::Session.new(:selenium_chrome_headless, Server.new)}
    let(:session2) {Capybara::Session.new(:selenium_chrome_headless, Server.new)}

    before(:each) do
      [session1, session2].each_with_index do |session, index|
        session.visit '/'
        session.fill_in :name, with: "Player #{index + 1}"
        session.click_on 'Join'
      end
      [session1, session2].each {|session| session.click_on 'Proceed to Game'}
    end

    before(:each) do
      game.players[0].set_hand([Card.new("3", "C"), Card.new("3", "D"),
        Card.new("3", "H")])
      game.players[1].set_hand([Card.new("3", "S")])
      game.deck.send(:set_cards, [])
      session1.click_on("Try to Take Turn")
    end

    it("redirects players in the waiting room to the game results when the "+
      "game is over", :js) do
      take_turn(session1, "3 of Clubs", "1")
      session1.click_on("Ok")
      expect(session2).to(have_content(game_result_header))
    end

    it("directs the player playing the last turn to the game results after "+
    "viewing the results of the last turn", :js) do
      take_turn(session1, "3 of Clubs", "1")
      session1.click_on("Ok")
      expect(session1).to(have_content(game_result_header))
    end
  end

  context "players pressing the 'try to take turn button'" do
    [:player1, :player2].each_with_index {|player, index| let(player) {Server.game.players[index]}}

    before(:each) do
      player1.set_hand([Card.new("K", "D")])
      player2.set_hand([Card.new("4", "S")])
      Server.game.deck.send(:set_cards, [Card.new("7", "C")])
      session1.click_on "Try to Take Turn"
      take_turn(session1, "King of Diamonds", "1")
    end

    it "links players to the take_turn page if it is their turn" do
      session1.click_on "Ok"
      session2.click_on "Try to Take Turn"
      expect(session2).to have_content("Take Your Turn")
    end

    it "redirects players to the waiting_room page if it isn't their turn" do
      session1.click_on "Ok"
      session1.click_on "Try to Take Turn"
      expect(session1).to_not have_content("Take Your Turn")
    end
  end

end
