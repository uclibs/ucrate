(function() {
  function updateMastheadHeight() {
    var masthead = document.getElementById('masthead');

    if (!masthead) {
      return;
    }

    var height = Math.ceil(masthead.getBoundingClientRect().height);

    if (height > 0) {
      document.documentElement.style.setProperty('--masthead-height', height + 'px');
    }
  }

  function scheduleHeightUpdate() {
    window.setTimeout(updateMastheadHeight, 0);
  }

  function bindEvents() {
    var collapse = $('#top-navbar-collapse');

    if (collapse.length) {
      collapse
        .off('.mastheadHeight')
        .on('shown.bs.collapse.mastheadHeight hidden.bs.collapse.mastheadHeight', scheduleHeightUpdate);
    }

    $(window)
      .off('resize.mastheadHeight orientationchange.mastheadHeight')
      .on('resize.mastheadHeight orientationchange.mastheadHeight', scheduleHeightUpdate);
  }

  $(document).on('turbolinks:load', function() {
    updateMastheadHeight();
    bindEvents();
  });
})();
