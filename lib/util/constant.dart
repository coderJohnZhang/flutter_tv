/// Design canvas. Every absolute coordinate and font size is expressed in these
/// units and scaled to the real screen at runtime.
const double kDesignWidth = 1920.0;
const double kDesignHeight = 1080.0;

/// Gap kept between the focused block and the content edges while scrolling.
const double kScrollPadding = 40.0;

/// Duration of the focus-box glide.
const Duration kFocusAnimation = Duration(milliseconds: 300);

/// Travel on a remote's touch surface, in design units, that amounts to one
/// press. Scaled to the real surface before use, so a drag costs the same
/// effort at any resolution.
const double kRemoteGestureStep = 400.0;

/// Bundled assets.
const String kBackgroundAsset = 'images/backgrounds/main_bg.webp';

/// The shape every bundled banner and tile image is drawn in.
///
/// Artwork is kept at this shape wherever it is placed, so nothing has to be
/// squeezed into a box it was not drawn for.
const double kArtworkAspect = 16.0 / 9.0;

/// Build of the launcher, sent to services that target a version.
const String kAppVersion = '2.0.0';

/// Focus zones. Exactly one holds the focus at a time.
enum FocusZone { topbar, title, content }

/// Tab identifiers, also used as the title widget keys.
const String kTabRecent = 'RECENT';
const String kTabHome = 'HOME';
const String kTabMovies = 'MOVIES';
const String kTabTv = 'TV';
const String kTabApps = 'APPS';

/// Layout config bundled with the app.
const String kLocalLayoutConfig = 'config/home_config.json';

/// Catalogs bundled with the app for the tabs that are not server-driven.
const String kLocalAppConfig = 'config/app_config.json';
const String kLocalVideoConfig = 'config/video_config.json';
const String kLocalTvConfig = 'config/tv_config.json';

/// Optional remote layout endpoint. While empty the bundled config is used.
const String kRemoteLayoutConfig = '';

/// Actions the status bar asks the host to resolve.
///
/// The launcher names the surface it wants opened and the host decides what
/// that is, so no platform interface is named here.
const String kActionInputSource = 'open_input_source';
const String kActionNetwork = 'open_network_settings';

/// Left margin of the first column of a grid layout, in design units.
const double kGridLeadingInset = 119.0;

/// Server-driven layout service.
///
/// The host owns the address, so the launcher ships no server name of its own:
/// while [kRemoteLayoutBaseUrl] is empty the bundled config is the only source.
/// The paths below are the shape of the service the mapper expects; point them
/// at the host's own endpoints.
const String kRemoteLayoutBaseUrl = '';
const String kLayoutTemplatePath = '/waterfall/layout';
const String kLayoutContentPath = '/waterfall/content';
const String kLayoutColumnPath = '/waterfall/column';

/// Path that issues this launcher its identifier, once.
const String kLayoutEnrolPath = '/device/enrol';

/// Rows requested per column page.
const int kColumnPageSize = 20;
