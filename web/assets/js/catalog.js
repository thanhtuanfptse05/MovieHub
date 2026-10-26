/* MovieHub catalog behaviour: poster fallback, video/YouTube player and episode switching. No inline scripts. */
(function () {
  'use strict';

  // Image error events do not bubble, so listen in the capture phase.
  document.addEventListener('error', function (event) {
    var el = event.target;
    if (el && el.tagName === 'IMG' && el.dataset && el.dataset.fallback && el.src !== el.dataset.fallback) {
      el.src = el.dataset.fallback;
    }
  }, true);

  var frameWrapper = document.getElementById('mh-frame-wrapper');
  var youtubePlayer = document.getElementById('mh-youtube-player');
  var videoPlayer = document.getElementById('mh-player');
  var currentEpTitle = document.getElementById('mh-current-ep-title');
  var btnPlayMovie = document.getElementById('mh-btn-play-movie');
  var btnPlayTrailer = document.getElementById('mh-btn-play-trailer');

  function setMediaSource(url, isYouTube, title) {
    if (!url) {
      return;
    }
    if (isYouTube) {
      if (videoPlayer) {
        videoPlayer.pause();
        videoPlayer.hidden = true;
      }
      if (youtubePlayer && frameWrapper) {
        youtubePlayer.src = url;
        frameWrapper.hidden = false;
      }
    } else {
      if (youtubePlayer && frameWrapper) {
        youtubePlayer.src = '';
        frameWrapper.hidden = true;
      }
      if (videoPlayer) {
        videoPlayer.src = url;
        videoPlayer.hidden = false;
        videoPlayer.load();
      }
    }

    if (title && currentEpTitle) {
      currentEpTitle.textContent = title;
    }
  }

  // Episode chip selection
  var epChips = document.querySelectorAll('.mh-ep-chip');
  if (epChips.length > 0) {
    epChips.forEach(function (chip) {
      chip.addEventListener('click', function (e) {
        // Progressive enhancement: prevent full reload when JS is active
        e.preventDefault();
        var url = chip.getAttribute('data-ep-url');
        var isYt = chip.getAttribute('data-is-youtube') === 'true';
        var title = chip.getAttribute('data-ep-title');
        var epNum = chip.getAttribute('data-ep-number');

        epChips.forEach(function (c) { c.classList.remove('is-active'); });
        chip.classList.add('is-active');

        setMediaSource(url, isYt, title);

        // Update movie button state if present
        if (btnPlayMovie) {
          btnPlayMovie.setAttribute('data-url', url);
          btnPlayMovie.setAttribute('data-is-youtube', isYt ? 'true' : 'false');
          btnPlayMovie.classList.add('is-active');
        }
        if (btnPlayTrailer) {
          btnPlayTrailer.classList.remove('is-active');
        }

        // Update browser URL without reload
        if (window.history && window.history.replaceState) {
          var currentUrl = new URL(window.location.href);
          currentUrl.searchParams.set('ep', epNum);
          window.history.replaceState({}, '', currentUrl.toString());
        }
      });
    });
  }

  // Toggle between Movie and Trailer
  if (btnPlayMovie && btnPlayTrailer) {
    btnPlayMovie.addEventListener('click', function () {
      var url = btnPlayMovie.getAttribute('data-url');
      var isYt = btnPlayMovie.getAttribute('data-is-youtube') === 'true';
      btnPlayMovie.classList.add('is-active');
      btnPlayTrailer.classList.remove('is-active');
      setMediaSource(url, isYt, null);
    });

    btnPlayTrailer.addEventListener('click', function () {
      var url = btnPlayTrailer.getAttribute('data-trailer-url');
      var isYt = btnPlayTrailer.getAttribute('data-is-youtube') === 'true';
      btnPlayTrailer.classList.add('is-active');
      btnPlayMovie.classList.remove('is-active');
      setMediaSource(url, isYt, 'Trailer');
    });
  }

  // Legacy fallback notice for MP4 video errors
  var notice = document.getElementById('mh-player-notice');
  var switchBtn = document.getElementById('mh-switch-trailer');
  var fallbackUrl = videoPlayer ? (videoPlayer.dataset.fallback || '') : '';
  var usedFallback = false;

  var DEFAULT_NOTICE = '\u004b\u0068\u00f4\u006e\u0067\u0020\u0070\u0068\u00e1\u0074\u0020\u0111\u01b0\u1ee3\u0063\u0020\u0076\u0069\u0064\u0065\u006f\u0020\u0063\u0068\u00ed\u006e\u0068\u002e\u0020\u0042\u1ea1\u006e\u0020\u0063\u00f3\u0020\u0074\u0068\u1ec3\u0020\u0063\u0068\u0075\u0079\u1ec3\u006e\u0020\u0073\u0061\u006e\u0067\u0020\u0074\u0072\u0061\u0069\u006c\u0065\u0072\u002e';
  var DEFAULT_FALLBACK_NOTICE = '\u004b\u0068\u00f4\u006e\u0067\u0020\u0070\u0068\u00e1\u0074\u0020\u0111\u01b0\u1ee3\u0063\u0020\u0076\u0069\u0064\u0065\u006f\u0020\u006e\u00e0\u0079\u0020\u0074\u0072\u00ea\u006e\u0020\u0074\u0072\u00ec\u006e\u0068\u0020\u0064\u0075\u0079\u1ec7\u0074\u0020\u0063\u1ee7\u0061\u0020\u0062\u1ea1\u006e\u002e';

  function showNotice(message) {
    if (notice) {
      notice.textContent = message;
      notice.hidden = false;
    }
  }

  if (videoPlayer) {
    videoPlayer.addEventListener('error', function () {
      if (fallbackUrl && !usedFallback) {
        if (switchBtn) {
          switchBtn.hidden = false;
        }
        showNotice(videoPlayer.dataset.errorNotice || DEFAULT_NOTICE);
      } else {
        showNotice(videoPlayer.dataset.errorFallback || DEFAULT_FALLBACK_NOTICE);
      }
    });
  }

  if (switchBtn) {
    switchBtn.addEventListener('click', function () {
      if (usedFallback || !fallbackUrl) {
        return;
      }
      usedFallback = true;
      switchBtn.hidden = true;
      if (notice) {
        notice.hidden = true;
      }
      if (videoPlayer) {
        videoPlayer.src = fallbackUrl;
        videoPlayer.load();
      }
    });
  }
})();
