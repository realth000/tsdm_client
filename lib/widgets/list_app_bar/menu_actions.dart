/// App bar actions.
enum MenuActions {
  /* Page related options */

  /// Refresh current page.
  refresh,

  /// Copy the url of current page to clipboard.
  copyUrl,

  /// Open the url of current page in external  browser.
  openInBrowser,

  /// Go back to top of the page.
  backToTop,

  /// Change the order when viewing current page.
  ///
  /// Only available to thread pages.
  reverseOrder,

  /* Global options */

  /// View contents in app.
  openInApp,

  /// Open search page.
  openSearchPage,

  /// Current user's profile.
  ///
  /// If logged in.
  profile,

  /// Open notification page.
  ///
  /// If logged in.
  openNoticePage,

  /// Open app settings page.
  openSettingsPage,

  /* Debug options */

  /// Debug option.
  ///
  /// View log.
  debugViewLog,

  /// Custom actions.
  custom,
}
