Pusher.logToConsole = true;

const pusher = new Pusher('cb19a8810ead6b423f1e', {
  cluster: 'us2',
  encrypted: true
});

const channel = pusher.subscribe('go-fish');
channel.bind('game-changed', function(data) {
  if(window.location.pathname === '/waiting_room') {
    window.location.reload();
  }
});

channel.bind('game-over', function(data) {
  if(window.location.pathname === '/waiting_room') {
    window.location.pathname = '/game_results';
    window.location.reload();
  }
});
