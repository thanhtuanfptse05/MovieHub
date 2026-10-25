/* MovieHub catalog behaviour: poster fallback and video fallback. No inline scripts. */
(function () {
  'use strict';

  // Image error events do not bubble, so listen in the capture phase.
  document.addEventListener('error', function (event) {
    var el = event.target;
    if (el && el.tagName === 'IMG' && el.dataset && el.dataset.fallback && el.src !== el.dataset.fallback) {
      el.src = el.dataset.fallback;
    }
  }, true);

  var player = document.getElementById('mh-player');
  if (!player) {
    return;
  }

  var notice = document.getElementById('mh-player-notice');
  var switchBtn = document.getElementById('mh-switch-trailer');
  var fallbackUrl = player.dataset.fallback || '';
  var usedFallback = false;

  // Unicode escape fallbacks guarantee zero mojibake regardless of server or browser encoding
  var DEFAULT_NOTICE = '\u004b\u0068\u00f4\u006e\u0067\u0020\u0070\u0068\u00e1\u0074\u0020\u0111\u01b0\u1ee3\u0063\u0020\u0076\u0069\u0064\u0065\u006f\u0020\u0063\u0068\u00ed\u006e\u0068\u002e\u0020\u0042\u1ea1\u006e\u0020\u0063\u00f3\u0020\u0074\u0068\u1ec3\u0020\u0063\u0068\u0075\u0079\u1ec3\u006e\u0020\u0073\u0061\u006e\u0067\u0020\u0074\u0072\u0061\u0069\u006c\u0065\u0072\u002e';
  var DEFAULT_FALLBACK_NOTICE = '\u004b\u0068\u00f4\u006e\u0067\u0020\u0070\u0068\u00e1\u0074\u0020\u0111\u01b0\u1ee3\u0063\u0020\u0076\u0069\u0064\u0065\u006f\u0020\u006e\u00e0\u0079\u0020\u0074\u0072\u00ea\u006e\u0020\u0074\u0072\u00ec\u006e\u0068\u0020\u0064\u0075\u0079\u1ec7\u0074\u0020\u0063\u1ee7\u0061\u0020\u0062\u1ea1\u006e\u002e';

  function showNotice(message) {
    if (notice) {
      notice.textContent = message;
      notice.hidden = false;
    }
  }

  player.addEventListener('error', function () {
    if (fallbackUrl && !usedFallback) {
      if (switchBtn) {
        switchBtn.hidden = false;
      }
      showNotice(player.dataset.errorNotice || DEFAULT_NOTICE);
    } else {
      showNotice(player.dataset.errorFallback || DEFAULT_FALLBACK_NOTICE);
    }
  });

  if (switchBtn) {
    switchBtn.addEventListener('click', function () {
      if (usedFallback || !fallbackUrl) {
        return;
      }
      usedFallback = true; // one switch only: no endless reload loop
      switchBtn.hidden = true;
      if (notice) {
        notice.hidden = true;
      }
      player.src = fallbackUrl;
      player.load();
    });
  }
})();
