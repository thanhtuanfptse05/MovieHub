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
      showNotice('Không phát được video chính. Bạn có thể chuyển sang trailer.');
    } else {
      showNotice('Không phát được video này trên trình duyệt của bạn.');
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
