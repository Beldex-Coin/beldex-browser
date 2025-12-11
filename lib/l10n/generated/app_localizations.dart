import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('ta'),
    Locale('tr'),
    Locale('vi'),
    Locale('zh')
  ];

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello 👋'**
  String get hello;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// No description provided for @exitnode.
  ///
  /// In en, this message translates to:
  /// **'Exit Node'**
  String get exitnode;

  /// No description provided for @beldexofficial.
  ///
  /// In en, this message translates to:
  /// **'Beldex official'**
  String get beldexofficial;

  /// No description provided for @contributorExitNode.
  ///
  /// In en, this message translates to:
  /// **'Contributor exit node'**
  String get contributorExitNode;

  /// No description provided for @belnetServiceStarted.
  ///
  /// In en, this message translates to:
  /// **'Belnet service started'**
  String get belnetServiceStarted;

  /// No description provided for @checkingConnection.
  ///
  /// In en, this message translates to:
  /// **'Checking for connection...'**
  String get checkingConnection;

  /// No description provided for @connectingBelnetdVPN.
  ///
  /// In en, this message translates to:
  /// **'Connecting to belnet dVPN'**
  String get connectingBelnetdVPN;

  /// No description provided for @prepareDaemonConnection.
  ///
  /// In en, this message translates to:
  /// **'Preparing Daemon connection'**
  String get prepareDaemonConnection;

  /// No description provided for @searchOrEnterAddress.
  ///
  /// In en, this message translates to:
  /// **'Search or enter Address'**
  String get searchOrEnterAddress;

  /// No description provided for @thistimeSearchIn.
  ///
  /// In en, this message translates to:
  /// **'This time Search in'**
  String get thistimeSearchIn;

  /// No description provided for @searchSettings.
  ///
  /// In en, this message translates to:
  /// **'Search settings'**
  String get searchSettings;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchEngine.
  ///
  /// In en, this message translates to:
  /// **'Search Engine'**
  String get searchEngine;

  /// No description provided for @defaultSearchEngine.
  ///
  /// In en, this message translates to:
  /// **'Default Search Engine'**
  String get defaultSearchEngine;

  /// No description provided for @manageSearchShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Manage Search shortcuts'**
  String get manageSearchShortcuts;

  /// No description provided for @editEnginesVisible.
  ///
  /// In en, this message translates to:
  /// **'Edit engines visible in the search menu'**
  String get editEnginesVisible;

  /// No description provided for @selectOne.
  ///
  /// In en, this message translates to:
  /// **'Select one'**
  String get selectOne;

  /// No description provided for @engineVisibleOnSearchMenu.
  ///
  /// In en, this message translates to:
  /// **'Engine visible on the search menu'**
  String get engineVisibleOnSearchMenu;

  /// No description provided for @newtab.
  ///
  /// In en, this message translates to:
  /// **'New tab'**
  String get newtab;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @changeNode.
  ///
  /// In en, this message translates to:
  /// **'Change Node'**
  String get changeNode;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @beldexAI.
  ///
  /// In en, this message translates to:
  /// **'Beldex AI'**
  String get beldexAI;

  /// No description provided for @webArchives.
  ///
  /// In en, this message translates to:
  /// **'Web Archives'**
  String get webArchives;

  /// No description provided for @findOnPage.
  ///
  /// In en, this message translates to:
  /// **'Find on page'**
  String get findOnPage;

  /// No description provided for @downloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloads;

  /// No description provided for @desktopMode.
  ///
  /// In en, this message translates to:
  /// **'Desktop mode'**
  String get desktopMode;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @reportAnIssue.
  ///
  /// In en, this message translates to:
  /// **'Report an Issue'**
  String get reportAnIssue;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @quit.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get quit;

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'No Favorites'**
  String get noFavorites;

  /// No description provided for @noWebArchives.
  ///
  /// In en, this message translates to:
  /// **'No Web archives'**
  String get noWebArchives;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @scanQR.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get scanQR;

  /// No description provided for @alignQRInCenterOFFrame.
  ///
  /// In en, this message translates to:
  /// **'Align the QR code in the\ncenter of frame'**
  String get alignQRInCenterOFFrame;

  /// No description provided for @beldexAIEnhancesTheBeldexBrowser.
  ///
  /// In en, this message translates to:
  /// **'Beldex AI enhances the Beldex Browser with intelligent features for a seamless web experience. It summarizes page content for quick reading. By efficiently routing traffic through masternodes and exit nodes, it ensures confidentiality and faster browsing. Unlike subscription-based models, Beldex AI is free to use, delivering advanced functionality while prioritizing user convenience and a confidentiality-centered internet experience. Explore smarter, faster browsing with Beldex AI.'**
  String get beldexAIEnhancesTheBeldexBrowser;

  /// No description provided for @needHelpWithThisSite.
  ///
  /// In en, this message translates to:
  /// **'Need help with this site?'**
  String get needHelpWithThisSite;

  /// No description provided for @beldexAICanHelpYou.
  ///
  /// In en, this message translates to:
  /// **'BeldexAI can help you summarize articles,\nexpand on a site\'s content and much more.'**
  String get beldexAICanHelpYou;

  /// No description provided for @enterPromptHere.
  ///
  /// In en, this message translates to:
  /// **'Enter prompt here..'**
  String get enterPromptHere;

  /// No description provided for @summariseThisPage.
  ///
  /// In en, this message translates to:
  /// **'Summarise this page'**
  String get summariseThisPage;

  /// No description provided for @hideSummarise.
  ///
  /// In en, this message translates to:
  /// **'Hide Summarise'**
  String get hideSummarise;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @regenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerate;

  /// No description provided for @thereWasAnErrorGenerateResponse.
  ///
  /// In en, this message translates to:
  /// **'There was an error generating response'**
  String get thereWasAnErrorGenerateResponse;

  /// No description provided for @askBeldexAI.
  ///
  /// In en, this message translates to:
  /// **'Ask Beldex AI'**
  String get askBeldexAI;

  /// No description provided for @chatDeleted.
  ///
  /// In en, this message translates to:
  /// **'Chat deleted successfully'**
  String get chatDeleted;

  /// No description provided for @unprecidentedTrafficExitNodeError.
  ///
  /// In en, this message translates to:
  /// **'Unprecedented traffic with Exit node. Please change exit node and retry'**
  String get unprecidentedTrafficExitNodeError;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @switchNode.
  ///
  /// In en, this message translates to:
  /// **'Switch Node'**
  String get switchNode;

  /// No description provided for @switchingNode.
  ///
  /// In en, this message translates to:
  /// **'Switching Node'**
  String get switchingNode;

  /// No description provided for @nodes.
  ///
  /// In en, this message translates to:
  /// **'Nodes'**
  String get nodes;

  /// No description provided for @exitNodeSwitched.
  ///
  /// In en, this message translates to:
  /// **'Exit node switched successfully'**
  String get exitNodeSwitched;

  /// No description provided for @thisNodeAlreadySelected.
  ///
  /// In en, this message translates to:
  /// **'This node is already selected.Please select another one from the list'**
  String get thisNodeAlreadySelected;

  /// No description provided for @doYouWantToSwitch.
  ///
  /// In en, this message translates to:
  /// **'Do you want to switch with the selected node?'**
  String get doYouWantToSwitch;

  /// No description provided for @noRecentDownloads.
  ///
  /// In en, this message translates to:
  /// **'No recent downloads'**
  String get noRecentDownloads;

  /// No description provided for @clearDownloads.
  ///
  /// In en, this message translates to:
  /// **'Clear Downloads'**
  String get clearDownloads;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @youAreAboutToDownload.
  ///
  /// In en, this message translates to:
  /// **'You are about to download'**
  String get youAreAboutToDownload;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// No description provided for @startDownloading.
  ///
  /// In en, this message translates to:
  /// **'Start downloading'**
  String get startDownloading;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading'**
  String get downloading;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @fileDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Files downloaded successfully'**
  String get fileDownloaded;

  /// No description provided for @searchEngineContent.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred search engine for personalized browsing.'**
  String get searchEngineContent;

  /// No description provided for @homePage.
  ///
  /// In en, this message translates to:
  /// **'Home Page'**
  String get homePage;

  /// No description provided for @homepageContent.
  ///
  /// In en, this message translates to:
  /// **'Set your homepage for quick access to favorite sites.'**
  String get homepageContent;

  /// No description provided for @screenSecurity.
  ///
  /// In en, this message translates to:
  /// **'Screen Security'**
  String get screenSecurity;

  /// No description provided for @screenSecurityContent.
  ///
  /// In en, this message translates to:
  /// **'Add an extra layer of protection for secure browsing'**
  String get screenSecurityContent;

  /// No description provided for @javascriptEnabled.
  ///
  /// In en, this message translates to:
  /// **'JavaScript Enabled'**
  String get javascriptEnabled;

  /// No description provided for @javascriptEnabledContent.
  ///
  /// In en, this message translates to:
  /// **'Enable or disable JavaScript for a tailored experience.'**
  String get javascriptEnabledContent;

  /// No description provided for @cacheEnabled.
  ///
  /// In en, this message translates to:
  /// **'Cache Enabled'**
  String get cacheEnabled;

  /// No description provided for @cacheEnabledContent.
  ///
  /// In en, this message translates to:
  /// **'Toggle caching for faster loading or increased confidentiality.'**
  String get cacheEnabledContent;

  /// No description provided for @supportZoom.
  ///
  /// In en, this message translates to:
  /// **'Support Zoom'**
  String get supportZoom;

  /// No description provided for @supportZoomContent.
  ///
  /// In en, this message translates to:
  /// **'Enable zoom for a closer look at web content.'**
  String get supportZoomContent;

  /// No description provided for @setAsDefaultBrowser.
  ///
  /// In en, this message translates to:
  /// **'Set as Default Browser'**
  String get setAsDefaultBrowser;

  /// No description provided for @appPermissions.
  ///
  /// In en, this message translates to:
  /// **'App Permissions'**
  String get appPermissions;

  /// No description provided for @aboutBeldexBrowser.
  ///
  /// In en, this message translates to:
  /// **'About Beldex Browser'**
  String get aboutBeldexBrowser;

  /// No description provided for @resetSettings.
  ///
  /// In en, this message translates to:
  /// **'Reset settings'**
  String get resetSettings;

  /// No description provided for @doYouWanttoReset.
  ///
  /// In en, this message translates to:
  /// **'Do you want to reset the browser\nsettings?'**
  String get doYouWanttoReset;

  /// No description provided for @textZoom.
  ///
  /// In en, this message translates to:
  /// **'Text Zoom'**
  String get textZoom;

  /// No description provided for @textZoomContent.
  ///
  /// In en, this message translates to:
  /// **'Customize text size in percentage for comfortable reading on any website.'**
  String get textZoomContent;

  /// No description provided for @adBlocker.
  ///
  /// In en, this message translates to:
  /// **'Ad Blocker'**
  String get adBlocker;

  /// No description provided for @adBlockerContent.
  ///
  /// In en, this message translates to:
  /// **'Toggle to block intrusive ads while browsing and enhance your browsing experience'**
  String get adBlockerContent;

  /// No description provided for @autoConnect.
  ///
  /// In en, this message translates to:
  /// **'Auto-Connect'**
  String get autoConnect;

  /// No description provided for @autoConnectContent.
  ///
  /// In en, this message translates to:
  /// **'Automatically connect when the app launches.'**
  String get autoConnectContent;

  /// No description provided for @autoSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Auto-Suggestion'**
  String get autoSuggestion;

  /// No description provided for @autoSuggestionContent.
  ///
  /// In en, this message translates to:
  /// **'Automatically display suggestions while searching.'**
  String get autoSuggestionContent;

  /// No description provided for @clearSessionCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Session Cache'**
  String get clearSessionCache;

  /// No description provided for @clearSessionCacheContent.
  ///
  /// In en, this message translates to:
  /// **'Automatically clear the current session\'s cache for confidentiality.'**
  String get clearSessionCacheContent;

  /// No description provided for @builtinZoomControls.
  ///
  /// In en, this message translates to:
  /// **'Built-In Zoom Controls'**
  String get builtinZoomControls;

  /// No description provided for @builtinZoomControlsContent.
  ///
  /// In en, this message translates to:
  /// **'Control your browsing experience with built-in zoom functionality.'**
  String get builtinZoomControlsContent;

  /// No description provided for @displayZoomControls.
  ///
  /// In en, this message translates to:
  /// **'Display Zoom Controls'**
  String get displayZoomControls;

  /// No description provided for @displayZoomControlsContent.
  ///
  /// In en, this message translates to:
  /// **'Show on-screen zoom controls for easy accessibility.'**
  String get displayZoomControlsContent;

  /// No description provided for @thirdpartCookiesEnabled.
  ///
  /// In en, this message translates to:
  /// **'Third-Party Cookies Enabled'**
  String get thirdpartCookiesEnabled;

  /// No description provided for @thirdpartyCookiesEnabledContent.
  ///
  /// In en, this message translates to:
  /// **'Enable or disable third-party cookies to manage your confidentiality while browsing.'**
  String get thirdpartyCookiesEnabledContent;

  /// No description provided for @debuggingEnabled.
  ///
  /// In en, this message translates to:
  /// **'Debugging Enabled'**
  String get debuggingEnabled;

  /// No description provided for @debuggingEnabledContent.
  ///
  /// In en, this message translates to:
  /// **'Activate debugging mode for advanced insights into performance.'**
  String get debuggingEnabledContent;

  /// No description provided for @beldexIsAnEcosystem.
  ///
  /// In en, this message translates to:
  /// **'Beldex is an ecosystem of decentralized and confidential preserving applications. The Beldex Browser app is one among this ecosystem which also consists of apps such as BChat, BelNet, and the Beldex protocol. The Beldex Browser is your gateway to a seamless and confidential online experience, where your data remains yours alone. Built on a robust blockchain infrastructure, Beldex browser ensures confidentiality and anonymity to its users.'**
  String get beldexIsAnEcosystem;

  /// No description provided for @atBeldex.
  ///
  /// In en, this message translates to:
  /// **' \n At Beldex, we believe in empowering individuals with the fundamental right to control their digital footprint. The Beldex Browser is designed to provide a secure and confidential online environment for users to communicate and interact with the digital world.'**
  String get atBeldex;

  /// No description provided for @titlebns.
  ///
  /// In en, this message translates to:
  /// **'\nBNS'**
  String get titlebns;

  /// No description provided for @theBeldexBrowserSupports.
  ///
  /// In en, this message translates to:
  /// **'The Beldex browser supports BNS domains. BNS domains are inherently hosted on BelNet. They can only be accessed by connecting to BelNet. However, since the Beldex Browser has BelNet in-built, users can freely access BNS domains.'**
  String get theBeldexBrowserSupports;

  /// No description provided for @titleMNApp.
  ///
  /// In en, this message translates to:
  /// **'\nMNApps'**
  String get titleMNApp;

  /// No description provided for @asTheBrowser.
  ///
  /// In en, this message translates to:
  /// **'As the browser itself supports BelNet as an added confidentiality feature, users can easily access MNApps hosting on the .bdx domain address.'**
  String get asTheBrowser;

  /// No description provided for @titleCrossplatformAccess.
  ///
  /// In en, this message translates to:
  /// **'\nCross Platform Access'**
  String get titleCrossplatformAccess;

  /// No description provided for @theBeldexBrowserIsCrossplatform.
  ///
  /// In en, this message translates to:
  /// **'The Beldex browser is cross-platform as it is being developed for both mobile and desktop devices.'**
  String get theBeldexBrowserIsCrossplatform;

  /// No description provided for @titleKeyFeature.
  ///
  /// In en, this message translates to:
  /// **'\nKey Features'**
  String get titleKeyFeature;

  /// No description provided for @followingAreTheFeatures.
  ///
  /// In en, this message translates to:
  /// **'\nFollowing are the features available on the Beta version of the Beldex browser application. More features will be added to the alpha version.\n'**
  String get followingAreTheFeatures;

  /// No description provided for @blockJavascript.
  ///
  /// In en, this message translates to:
  /// **'Blocks Javascript: The Beldex browser prioritizes user security by blocking Javascript, thereby reducing the risk of malicious scripts that could compromise user confidentiality and security. This ensures a safe browsing experience and protects users from threats that involve javascript vulnerabilities.'**
  String get blockJavascript;

  /// No description provided for @blockcookies.
  ///
  /// In en, this message translates to:
  /// **'Blocks Cookies: Cookies collect a user’s personal information that help determine their behavioural and usage patterns. This in-turn helps the website to show relevant ads, manage active sessions, and provide big data analytics.'**
  String get blockcookies;

  /// No description provided for @ipAddressMasked.
  ///
  /// In en, this message translates to:
  /// **'IP Address is Masked: The browser’s in-built dVPN, the BelNet, masks the client IP address from the websites they visit. This provides confidentiality and anonymity to the user and prevents websites from identifying and tracking the user based on their IP address.'**
  String get ipAddressMasked;

  /// No description provided for @locationObfuscated.
  ///
  /// In en, this message translates to:
  /// **'Location is Obfuscated: To further enhance confidentiality, the browser obfuscates the user\'s location, making it challenging for websites and third parties to determine the actual geographical location of the user. This ensures that users can browse without revealing sensitive information about their whereabouts.'**
  String get locationObfuscated;

  /// No description provided for @noMetadataCallected.
  ///
  /// In en, this message translates to:
  /// **'No Metadata is Collected: The browser abstains from collecting metadata, ensuring that no additional information about the user\'s browsing habits or preferences is stored. This minimizes the risk of data leakage and unauthorized access to user information.'**
  String get noMetadataCallected;

  /// No description provided for @inbuiltdVPN.
  ///
  /// In en, this message translates to:
  /// **'In-built dVPN Service: The inclusion of an in-built decentralized VPN (dVPN) service like BelNet encrypts the user’s internet traffic and ensures a secure and confidential connection for users.'**
  String get inbuiltdVPN;

  /// No description provided for @unrestrictedAccess.
  ///
  /// In en, this message translates to:
  /// **'Unrestricted Access: The Beldex browser promotes unrestricted access to information on the Internet, thus aiding free speech and resistance to censorship. Users can easily access geo-restricted content.'**
  String get unrestrictedAccess;

  /// No description provided for @censorshipResistance.
  ///
  /// In en, this message translates to:
  /// **'Censorship-resistance: By employing the Beldex blockchain and a network of decentralized nodes, Beldex browser promotes resistance to censorship. The outage of no single server can restrict access to the service.\n'**
  String get censorshipResistance;

  /// No description provided for @aboutAdblocker.
  ///
  /// In en, this message translates to:
  /// **'Ad-blocker: Block intrusive ads, trackers, and pop-ups for a cleaner, distraction-free browsing experience. Enjoy faster page loads and reduced data usage while maintaining complete control over your online interactions.\n'**
  String get aboutAdblocker;

  /// No description provided for @aboutBeldexAI.
  ///
  /// In en, this message translates to:
  /// **'Beldex AI: Get instant answers to your queries with BeldexAI, an intelligent assistant that responds to your questions and queries based on website content. Whether you\'re searching for specific information or need quick insights, BeldexAI enhances your browsing experience with contextual and tailored responses.\n'**
  String get aboutBeldexAI;

  /// No description provided for @thusbeldexbrowserOffers.
  ///
  /// In en, this message translates to:
  /// **'\nThus, the Beldex Browser offers a simple and secure haven for users seeking confidentiality in an increasingly interconnected world. Join us on the journey towards a more confidential and secure digital future. Experience the freedom to surf, communicate, and explore the internet without compromising your confidentiality. Beldex Network – Where Confidentiality Meets Innovation.'**
  String get thusbeldexbrowserOffers;

  /// No description provided for @credits.
  ///
  /// In en, this message translates to:
  /// **'\nCredits: Beldex & BelNet.\n'**
  String get credits;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'de', 'en', 'es', 'ja', 'ko', 'pt', 'ru', 'ta', 'tr', 'vi', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'ja': return AppLocalizationsJa();
    case 'ko': return AppLocalizationsKo();
    case 'pt': return AppLocalizationsPt();
    case 'ru': return AppLocalizationsRu();
    case 'ta': return AppLocalizationsTa();
    case 'tr': return AppLocalizationsTr();
    case 'vi': return AppLocalizationsVi();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
