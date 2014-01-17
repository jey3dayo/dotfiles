(function() {
  var SpeakerDeck = function() {
    var doc = content.document;
    if (doc.location.host !== 'speakerdeck.com') {
      return liberator.echoerr('Current page is not speakerdeck.');
    }

    var iframe = doc.wrappedJSObject.getElementsByClassName('speakerdeck-iframe')[0];
    var player = iframe.contentWindow.player;

    return {
      next: function() {
        player.nextSlide();
      },
      prev: function() {
        player.previousSlide();
      }
    }
  };

  commands.addUserCommand(
    ['speakerdeck'],
    'Speaker Deck controller',
    function() {},
    {
      subCommands: [
        new Command(['n[ext]'], 'Go next page',     function() SpeakerDeck().next()),
        new Command(['p[rev]'], 'Go previous page', function() SpeakerDeck().prev()),
      ]
    },
    true
  );
})();