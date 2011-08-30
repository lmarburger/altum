/******************************************************
 ** Copy the latest pusher.min.js and paste it here. **
 ** http://js.pusherapp.com/1.9/pusher.min.js        **
 ******************************************************/

var presenter = /presenter=(.*)/.exec(window.location.search),
    sekret    = presenter && presenter[1];

if (sekret) {
  $(function() {
    $('body').bind('showoff:show', function() {
      $.post('/slide', { key: sekret, number: slidenum });
    });
  });

} else {

  // Enable pusher logging - don't include this in production
  Pusher.log = function(message) {
    if (window.console && window.console.log) window.console.log(message);
  };

  new Pusher('06d2e0409a41c6e5a7d4')
    .subscribe('presenter')
    .bind('slide_change', function(data) {
      gotoSlide(data.slide);
    });
}
