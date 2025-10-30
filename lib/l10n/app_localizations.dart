import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('fr'),
    Locale('it'),
    Locale('pt')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Swap&Shop'**
  String get appTitle;

  /// Home tab label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Matches tab label
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get matches;

  /// Groups tab label
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// Chat tab label
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// Profile tab label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Text shown when no items are available
  ///
  /// In en, this message translates to:
  /// **'No items available'**
  String get noItems;

  /// Search field hint text
  ///
  /// In en, this message translates to:
  /// **'Enter search term'**
  String get searchHint;

  /// Filter dialog title
  ///
  /// In en, this message translates to:
  /// **'Filter options'**
  String get filterTitle;

  /// Text shown when no matches are available
  ///
  /// In en, this message translates to:
  /// **'No matches yet'**
  String get noMatches;

  /// Text shown when no likes are available
  ///
  /// In en, this message translates to:
  /// **'No likes yet'**
  String get noLikes;

  /// Text shown when user hasn't liked anyone
  ///
  /// In en, this message translates to:
  /// **'You haven\'t liked anyone yet'**
  String get noMyLikes;

  /// Liked tab label
  ///
  /// In en, this message translates to:
  /// **'Liked'**
  String get liked;

  /// No description provided for @disliked.
  ///
  /// In en, this message translates to:
  /// **'Disliked'**
  String get disliked;

  /// Likes tab label
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get likes;

  /// Matches tab label
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get matchesTab;

  /// Create listing button text
  ///
  /// In en, this message translates to:
  /// **'Create Listing'**
  String get createListing;

  /// Create listing screen title
  ///
  /// In en, this message translates to:
  /// **'Create new listing'**
  String get createListingTitle;

  /// Title field label
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// Title field hint text
  ///
  /// In en, this message translates to:
  /// **'e.g. Snowboard, barely used'**
  String get titleHint;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Description field hint text
  ///
  /// In en, this message translates to:
  /// **'Describe your item'**
  String get descriptionHint;

  /// Category field label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Condition field label
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get condition;

  /// Location field label
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// Location field hint text
  ///
  /// In en, this message translates to:
  /// **'e.g. Zermatt'**
  String get locationHint;

  /// Price field label
  ///
  /// In en, this message translates to:
  /// **'Price (CHF)'**
  String get price;

  /// Price field hint text
  ///
  /// In en, this message translates to:
  /// **'e.g. 25'**
  String get priceHint;

  /// Images field label
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Privacy section title
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// Privacy section description
  ///
  /// In en, this message translates to:
  /// **'Decide whether your name and profile picture should be displayed'**
  String get privacyDescription;

  /// Anonymous posting checkbox text
  ///
  /// In en, this message translates to:
  /// **'Post this item anonymously'**
  String get postAnonymously;

  /// Anonymous posting description
  ///
  /// In en, this message translates to:
  /// **'Your name will be displayed as \'Anonymous\''**
  String get anonymousDescription;

  /// Anonymous user display name
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get anonymous;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Dark mode setting label
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Light mode setting label
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemMode;

  /// Notifications setting label
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Push notifications subtitle
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// Location access setting label
  ///
  /// In en, this message translates to:
  /// **'Location Access'**
  String get locationAccess;

  /// Location for search subtitle
  ///
  /// In en, this message translates to:
  /// **'Location for Search'**
  String get locationForSearch;

  /// Edit profile setting label
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Edit profile setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Change name, image, location'**
  String get editProfileSubtitle;

  /// Change password setting label
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// Change password setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Set secure password'**
  String get changePasswordSubtitle;

  /// Blocked users setting label
  ///
  /// In en, this message translates to:
  /// **'Blocked Users'**
  String get blockedUsers;

  /// Manage users subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage users'**
  String get manageUsers;

  /// Default category setting label
  ///
  /// In en, this message translates to:
  /// **'Default Category'**
  String get defaultCategory;

  /// Default radius setting label
  ///
  /// In en, this message translates to:
  /// **'Default Radius'**
  String get defaultRadius;

  /// About setting label
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// App information subtitle
  ///
  /// In en, this message translates to:
  /// **'App information'**
  String get appInfo;

  /// Feedback setting label
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// Suggestions subtitle
  ///
  /// In en, this message translates to:
  /// **'Improvement suggestions'**
  String get suggestions;

  /// Report problem setting label
  ///
  /// In en, this message translates to:
  /// **'Report Problem'**
  String get reportProblem;

  /// Report problem subtitle
  ///
  /// In en, this message translates to:
  /// **'Report errors or problems'**
  String get reportProblemSubtitle;

  /// Privacy and terms setting label
  ///
  /// In en, this message translates to:
  /// **'Privacy & Terms'**
  String get privacyTerms;

  /// Legal information subtitle
  ///
  /// In en, this message translates to:
  /// **'Legal information'**
  String get legalInfo;

  /// Imprint setting label
  ///
  /// In en, this message translates to:
  /// **'Imprint'**
  String get imprint;

  /// Contact and legal subtitle
  ///
  /// In en, this message translates to:
  /// **'Contact and legal information'**
  String get contactLegal;

  /// Logout setting label
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Logout subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign out of app'**
  String get logoutSubtitle;

  /// Delete account setting label
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Delete account subtitle
  ///
  /// In en, this message translates to:
  /// **'Permanently delete account'**
  String get deleteAccountSubtitle;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Send button text
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Block button text
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// Block user dialog title
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get blockUser;

  /// Anonymous post checkbox label
  ///
  /// In en, this message translates to:
  /// **'Post this article anonymously'**
  String get anonymousPost;

  /// Anonymous post checkbox subtitle
  ///
  /// In en, this message translates to:
  /// **'Your name and profile picture will not be displayed'**
  String get anonymousPostSubtitle;

  /// Owner name field label
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get ownerName;

  /// Owner name field hint text
  ///
  /// In en, this message translates to:
  /// **'e.g. John D.'**
  String get ownerNameHint;

  /// Swap value field label
  ///
  /// In en, this message translates to:
  /// **'Estimated Value (CHF)'**
  String get swapValue;

  /// Swap value field hint text
  ///
  /// In en, this message translates to:
  /// **'e.g. 50'**
  String get swapValueHint;

  /// Desired swap item field label
  ///
  /// In en, this message translates to:
  /// **'What would you like to swap for? (optional)'**
  String get desiredSwapItem;

  /// Desired swap item field hint text
  ///
  /// In en, this message translates to:
  /// **'e.g. Kitchen items, Snowboard M'**
  String get desiredSwapItemHint;

  /// Tags field label
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// Tags field hint text
  ///
  /// In en, this message translates to:
  /// **'e.g. Snowboard, Burton, Freestyle'**
  String get tagsHint;

  /// Create listing button text
  ///
  /// In en, this message translates to:
  /// **'Create Listing'**
  String get createListingButton;

  /// Listing created confirmation message
  ///
  /// In en, this message translates to:
  /// **'Listing created'**
  String get listingCreated;

  /// Save profile button text
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get saveProfile;

  /// Profile saved confirmation message
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// Search dialog title
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// Search button text
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchButton;

  /// Apply filter button text
  ///
  /// In en, this message translates to:
  /// **'Apply Filter'**
  String get filterApply;

  /// Radius filter label
  ///
  /// In en, this message translates to:
  /// **'Radius:'**
  String get radius;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// On option
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// Off option
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// Language change confirmation message
  ///
  /// In en, this message translates to:
  /// **'Language changed to:'**
  String get languageChanged;

  /// Location permission denied message
  ///
  /// In en, this message translates to:
  /// **'Location permission denied.'**
  String get locationPermissionDenied;

  /// Location permission permanently denied message
  ///
  /// In en, this message translates to:
  /// **'Location permission permanently denied.'**
  String get locationPermissionDeniedForever;

  /// Account deleted confirmation message
  ///
  /// In en, this message translates to:
  /// **'Account successfully deleted'**
  String get accountDeleted;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Logout successful'**
  String get logoutSuccessful;

  /// Send feedback dialog title
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get sendFeedback;

  /// Feedback dialog message
  ///
  /// In en, this message translates to:
  /// **'We would love to hear your opinion! Share your feedback with us to help us improve Swap&Shop.'**
  String get feedbackMessage;

  /// Delete account dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccountTitle;

  /// Delete account dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get deleteAccountMessage;

  /// About dialog title
  ///
  /// In en, this message translates to:
  /// **'About Swap&Shop'**
  String get aboutTitle;

  /// About dialog message
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0\\n\\nAn app for swapping, giving away and selling items in your area.'**
  String get aboutMessage;

  /// Report problem dialog title
  ///
  /// In en, this message translates to:
  /// **'Report problem'**
  String get reportProblemTitle;

  /// Report problem dialog message
  ///
  /// In en, this message translates to:
  /// **'Please send us an email to:\\nsupport@swapshop.ch\\n\\nDescribe the problem as precisely as possible.'**
  String get reportProblemMessage;

  /// Privacy and terms dialog title
  ///
  /// In en, this message translates to:
  /// **'Privacy & Terms'**
  String get privacyTermsTitle;

  /// Privacy and terms dialog message
  ///
  /// In en, this message translates to:
  /// **'Privacy policy and terms of use\\n\\nAll information can be found on our website: swapshop.ch'**
  String get privacyTermsMessage;

  /// Imprint dialog title
  ///
  /// In en, this message translates to:
  /// **'Legal notice'**
  String get imprintTitle;

  /// Imprint dialog message
  ///
  /// In en, this message translates to:
  /// **'Swap&Shop GmbH\\nExample Street 123\\n8000 Zurich\\nSwitzerland\\n\\nEmail: info@swapshop.ch\\nPhone: +41 44 123 45 67'**
  String get imprintMessage;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Groups subtitle
  ///
  /// In en, this message translates to:
  /// **'Create or manage your groups'**
  String get groupsSubtitle;

  /// My listings label
  ///
  /// In en, this message translates to:
  /// **'My listings'**
  String get myListings;

  /// Edit listing label
  ///
  /// In en, this message translates to:
  /// **'Edit listing'**
  String get editListing;

  /// Chats screen title
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chatsTitle;

  /// Chat title
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chatTitle;

  /// No chats message
  ///
  /// In en, this message translates to:
  /// **'No chats available.'**
  String get noChats;

  /// Message input hint
  ///
  /// In en, this message translates to:
  /// **'Enter message...'**
  String get typeMessage;

  /// Matches headline
  ///
  /// In en, this message translates to:
  /// **'✅ Your matches'**
  String get matchesHeadline;

  /// Liked headline
  ///
  /// In en, this message translates to:
  /// **'🤍 Liked, but no match'**
  String get likedHeadline;

  /// No matches or likes message
  ///
  /// In en, this message translates to:
  /// **'No matches or likes yet.'**
  String get noMatchesOrLikes;

  /// My liked tab label
  ///
  /// In en, this message translates to:
  /// **'Liked'**
  String get myLikedTab;

  /// Block user dialog title
  ///
  /// In en, this message translates to:
  /// **'Block user'**
  String get blockUserTitle;

  /// Block user dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to block this user?'**
  String get blockUserMessage;

  /// Blocked users screen title
  ///
  /// In en, this message translates to:
  /// **'Blocked users'**
  String get blockedUsersTitle;

  /// New post button text
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newItem;

  /// Invite members button text
  ///
  /// In en, this message translates to:
  /// **'Invite members'**
  String get inviteMembers;

  /// Manage group button text
  ///
  /// In en, this message translates to:
  /// **'Manage group'**
  String get manageGroup;

  /// Delete group button text
  ///
  /// In en, this message translates to:
  /// **'Delete group'**
  String get deleteGroup;

  /// Delete group confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this group? This action cannot be undone.'**
  String get deleteGroupMessage;

  /// Edit profile screen title
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileTitle;

  /// Change password screen title
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordTitle;

  /// Current password field label
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// New password field label
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// Password changed confirmation message
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChanged;

  /// Password mismatch error message
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Create group button text
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get createGroup;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @premiumMember.
  ///
  /// In en, this message translates to:
  /// **'Premium Member'**
  String get premiumMember;

  /// No description provided for @validUntil.
  ///
  /// In en, this message translates to:
  /// **'Valid until'**
  String get validUntil;

  /// No description provided for @donationsOverview.
  ///
  /// In en, this message translates to:
  /// **'Donations overview'**
  String get donationsOverview;

  /// No description provided for @youHaveDonated.
  ///
  /// In en, this message translates to:
  /// **'You have donated CHF {amount}'**
  String youHaveDonated(Object amount);

  /// No description provided for @communityCreate.
  ///
  /// In en, this message translates to:
  /// **'Create community'**
  String get communityCreate;

  /// No description provided for @locationPermission.
  ///
  /// In en, this message translates to:
  /// **'Location permission'**
  String get locationPermission;

  /// No description provided for @groupsDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover groups'**
  String get groupsDiscover;

  /// No description provided for @findNewCommunities.
  ///
  /// In en, this message translates to:
  /// **'Find new communities'**
  String get findNewCommunities;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @darkModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Enable dark theme'**
  String get darkModeDescription;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System Theme'**
  String get systemTheme;

  /// No description provided for @systemThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatically adapt to system'**
  String get systemThemeDescription;

  /// No description provided for @locationDescription.
  ///
  /// In en, this message translates to:
  /// **'For better search results in your area'**
  String get locationDescription;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get version;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Swap&Shop is a platform for swapping, giving away and selling items in your area.'**
  String get aboutDescription;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// No description provided for @emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get emailNotifications;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @autoPlay.
  ///
  /// In en, this message translates to:
  /// **'Auto Play'**
  String get autoPlay;

  /// No description provided for @dataUsage.
  ///
  /// In en, this message translates to:
  /// **'Data Usage'**
  String get dataUsage;

  /// No description provided for @cache.
  ///
  /// In en, this message translates to:
  /// **'Cache'**
  String get cache;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @freeSpace.
  ///
  /// In en, this message translates to:
  /// **'Free Space'**
  String get freeSpace;

  /// No description provided for @usedSpace.
  ///
  /// In en, this message translates to:
  /// **'Used Space'**
  String get usedSpace;

  /// No description provided for @network.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get network;

  /// No description provided for @wifiOnly.
  ///
  /// In en, this message translates to:
  /// **'WiFi Only'**
  String get wifiOnly;

  /// No description provided for @mobileData.
  ///
  /// In en, this message translates to:
  /// **'Mobile Data'**
  String get mobileData;

  /// No description provided for @roaming.
  ///
  /// In en, this message translates to:
  /// **'Roaming'**
  String get roaming;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @biometric.
  ///
  /// In en, this message translates to:
  /// **'Biometric'**
  String get biometric;

  /// No description provided for @fingerprint.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint'**
  String get fingerprint;

  /// No description provided for @faceId.
  ///
  /// In en, this message translates to:
  /// **'Face ID'**
  String get faceId;

  /// No description provided for @pinCode.
  ///
  /// In en, this message translates to:
  /// **'PIN Code'**
  String get pinCode;

  /// No description provided for @twoFactor.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get twoFactor;

  /// No description provided for @accessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibility;

  /// No description provided for @largeText.
  ///
  /// In en, this message translates to:
  /// **'Large Text'**
  String get largeText;

  /// No description provided for @highContrast.
  ///
  /// In en, this message translates to:
  /// **'High Contrast'**
  String get highContrast;

  /// No description provided for @screenReader.
  ///
  /// In en, this message translates to:
  /// **'Screen Reader'**
  String get screenReader;

  /// No description provided for @voiceOver.
  ///
  /// In en, this message translates to:
  /// **'VoiceOver'**
  String get voiceOver;

  /// No description provided for @talkBack.
  ///
  /// In en, this message translates to:
  /// **'TalkBack'**
  String get talkBack;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @debug.
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get debug;

  /// No description provided for @logs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logs;

  /// No description provided for @crashReports.
  ///
  /// In en, this message translates to:
  /// **'Crash Reports'**
  String get crashReports;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @telemetry.
  ///
  /// In en, this message translates to:
  /// **'Telemetry'**
  String get telemetry;

  /// No description provided for @beta.
  ///
  /// In en, this message translates to:
  /// **'Beta'**
  String get beta;

  /// No description provided for @experimental.
  ///
  /// In en, this message translates to:
  /// **'Experimental'**
  String get experimental;

  /// No description provided for @unstable.
  ///
  /// In en, this message translates to:
  /// **'Unstable'**
  String get unstable;

  /// No description provided for @deprecated.
  ///
  /// In en, this message translates to:
  /// **'Deprecated'**
  String get deprecated;

  /// No description provided for @legacy.
  ///
  /// In en, this message translates to:
  /// **'Legacy'**
  String get legacy;

  /// No description provided for @migration.
  ///
  /// In en, this message translates to:
  /// **'Migration'**
  String get migration;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @downgrade.
  ///
  /// In en, this message translates to:
  /// **'Downgrade'**
  String get downgrade;

  /// No description provided for @rollback.
  ///
  /// In en, this message translates to:
  /// **'Rollback'**
  String get rollback;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @factoryReset.
  ///
  /// In en, this message translates to:
  /// **'Factory Reset'**
  String get factoryReset;

  /// No description provided for @clearData.
  ///
  /// In en, this message translates to:
  /// **'Clear Data'**
  String get clearData;

  /// No description provided for @uninstall.
  ///
  /// In en, this message translates to:
  /// **'Uninstall'**
  String get uninstall;

  /// No description provided for @reinstall.
  ///
  /// In en, this message translates to:
  /// **'Reinstall'**
  String get reinstall;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for Updates'**
  String get checkForUpdates;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @install.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get install;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// No description provided for @shutdown.
  ///
  /// In en, this message translates to:
  /// **'Shutdown'**
  String get shutdown;

  /// No description provided for @sleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// No description provided for @wake.
  ///
  /// In en, this message translates to:
  /// **'Wake'**
  String get wake;

  /// No description provided for @lock.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get lock;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @minimize.
  ///
  /// In en, this message translates to:
  /// **'Minimize'**
  String get minimize;

  /// No description provided for @maximize.
  ///
  /// In en, this message translates to:
  /// **'Maximize'**
  String get maximize;

  /// No description provided for @fullscreen.
  ///
  /// In en, this message translates to:
  /// **'Fullscreen'**
  String get fullscreen;

  /// No description provided for @windowed.
  ///
  /// In en, this message translates to:
  /// **'Windowed'**
  String get windowed;

  /// No description provided for @split.
  ///
  /// In en, this message translates to:
  /// **'Split'**
  String get split;

  /// No description provided for @merge.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get merge;

  /// No description provided for @duplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicate;

  /// No description provided for @clone.
  ///
  /// In en, this message translates to:
  /// **'Clone'**
  String get clone;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @paste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get paste;

  /// No description provided for @cut.
  ///
  /// In en, this message translates to:
  /// **'Cut'**
  String get cut;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @deselect.
  ///
  /// In en, this message translates to:
  /// **'Deselect'**
  String get deselect;

  /// No description provided for @invert.
  ///
  /// In en, this message translates to:
  /// **'Invert'**
  String get invert;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @group.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get group;

  /// No description provided for @ungroup.
  ///
  /// In en, this message translates to:
  /// **'Ungroup'**
  String get ungroup;

  /// No description provided for @expand.
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get expand;

  /// No description provided for @collapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get collapse;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @hide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;

  /// No description provided for @toggle.
  ///
  /// In en, this message translates to:
  /// **'Toggle'**
  String get toggle;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @disable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// No description provided for @auto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get auto;

  /// No description provided for @manual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manual;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @preset.
  ///
  /// In en, this message translates to:
  /// **'Preset'**
  String get preset;

  /// No description provided for @template.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get template;

  /// No description provided for @configuration.
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get configuration;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// No description provided for @properties.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get properties;

  /// No description provided for @attributes.
  ///
  /// In en, this message translates to:
  /// **'Attributes'**
  String get attributes;

  /// No description provided for @metadata.
  ///
  /// In en, this message translates to:
  /// **'Metadata'**
  String get metadata;

  /// No description provided for @labels.
  ///
  /// In en, this message translates to:
  /// **'Labels'**
  String get labels;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @types.
  ///
  /// In en, this message translates to:
  /// **'Types'**
  String get types;

  /// No description provided for @classes.
  ///
  /// In en, this message translates to:
  /// **'Classes'**
  String get classes;

  /// No description provided for @interfaces.
  ///
  /// In en, this message translates to:
  /// **'Interfaces'**
  String get interfaces;

  /// No description provided for @modules.
  ///
  /// In en, this message translates to:
  /// **'Modules'**
  String get modules;

  /// No description provided for @packages.
  ///
  /// In en, this message translates to:
  /// **'Packages'**
  String get packages;

  /// No description provided for @libraries.
  ///
  /// In en, this message translates to:
  /// **'Libraries'**
  String get libraries;

  /// No description provided for @frameworks.
  ///
  /// In en, this message translates to:
  /// **'Frameworks'**
  String get frameworks;

  /// No description provided for @platforms.
  ///
  /// In en, this message translates to:
  /// **'Platforms'**
  String get platforms;

  /// No description provided for @devices.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get devices;

  /// No description provided for @sensors.
  ///
  /// In en, this message translates to:
  /// **'Sensors'**
  String get sensors;

  /// No description provided for @cameras.
  ///
  /// In en, this message translates to:
  /// **'Cameras'**
  String get cameras;

  /// No description provided for @microphones.
  ///
  /// In en, this message translates to:
  /// **'Microphones'**
  String get microphones;

  /// No description provided for @speakers.
  ///
  /// In en, this message translates to:
  /// **'Speakers'**
  String get speakers;

  /// No description provided for @displays.
  ///
  /// In en, this message translates to:
  /// **'Displays'**
  String get displays;

  /// No description provided for @keyboards.
  ///
  /// In en, this message translates to:
  /// **'Keyboards'**
  String get keyboards;

  /// No description provided for @mice.
  ///
  /// In en, this message translates to:
  /// **'Mice'**
  String get mice;

  /// No description provided for @touchpads.
  ///
  /// In en, this message translates to:
  /// **'Touchpads'**
  String get touchpads;

  /// No description provided for @gamepads.
  ///
  /// In en, this message translates to:
  /// **'Gamepads'**
  String get gamepads;

  /// No description provided for @controllers.
  ///
  /// In en, this message translates to:
  /// **'Controllers'**
  String get controllers;

  /// No description provided for @remotes.
  ///
  /// In en, this message translates to:
  /// **'Remotes'**
  String get remotes;

  /// No description provided for @headsets.
  ///
  /// In en, this message translates to:
  /// **'Headsets'**
  String get headsets;

  /// No description provided for @earbuds.
  ///
  /// In en, this message translates to:
  /// **'Earbuds'**
  String get earbuds;

  /// No description provided for @watches.
  ///
  /// In en, this message translates to:
  /// **'Watches'**
  String get watches;

  /// No description provided for @bands.
  ///
  /// In en, this message translates to:
  /// **'Bands'**
  String get bands;

  /// No description provided for @rings.
  ///
  /// In en, this message translates to:
  /// **'Rings'**
  String get rings;

  /// No description provided for @glasses.
  ///
  /// In en, this message translates to:
  /// **'Glasses'**
  String get glasses;

  /// No description provided for @lenses.
  ///
  /// In en, this message translates to:
  /// **'Lenses'**
  String get lenses;

  /// No description provided for @frames.
  ///
  /// In en, this message translates to:
  /// **'Frames'**
  String get frames;

  /// No description provided for @straps.
  ///
  /// In en, this message translates to:
  /// **'Straps'**
  String get straps;

  /// No description provided for @cases.
  ///
  /// In en, this message translates to:
  /// **'Cases'**
  String get cases;

  /// No description provided for @covers.
  ///
  /// In en, this message translates to:
  /// **'Covers'**
  String get covers;

  /// No description provided for @protectors.
  ///
  /// In en, this message translates to:
  /// **'Protectors'**
  String get protectors;

  /// No description provided for @stands.
  ///
  /// In en, this message translates to:
  /// **'Stands'**
  String get stands;

  /// No description provided for @docks.
  ///
  /// In en, this message translates to:
  /// **'Docks'**
  String get docks;

  /// No description provided for @chargers.
  ///
  /// In en, this message translates to:
  /// **'Chargers'**
  String get chargers;

  /// No description provided for @cables.
  ///
  /// In en, this message translates to:
  /// **'Cables'**
  String get cables;

  /// No description provided for @adapters.
  ///
  /// In en, this message translates to:
  /// **'Adapters'**
  String get adapters;

  /// No description provided for @hubs.
  ///
  /// In en, this message translates to:
  /// **'Hubs'**
  String get hubs;

  /// No description provided for @routers.
  ///
  /// In en, this message translates to:
  /// **'Routers'**
  String get routers;

  /// No description provided for @modems.
  ///
  /// In en, this message translates to:
  /// **'Modems'**
  String get modems;

  /// No description provided for @antennas.
  ///
  /// In en, this message translates to:
  /// **'Antennas'**
  String get antennas;

  /// No description provided for @receivers.
  ///
  /// In en, this message translates to:
  /// **'Receivers'**
  String get receivers;

  /// No description provided for @transmitters.
  ///
  /// In en, this message translates to:
  /// **'Transmitters'**
  String get transmitters;

  /// No description provided for @amplifiers.
  ///
  /// In en, this message translates to:
  /// **'Amplifiers'**
  String get amplifiers;

  /// No description provided for @mixers.
  ///
  /// In en, this message translates to:
  /// **'Mixers'**
  String get mixers;

  /// No description provided for @processors.
  ///
  /// In en, this message translates to:
  /// **'Processors'**
  String get processors;

  /// No description provided for @memory.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get memory;

  /// No description provided for @drives.
  ///
  /// In en, this message translates to:
  /// **'Drives'**
  String get drives;

  /// No description provided for @cards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get cards;

  /// No description provided for @sticks.
  ///
  /// In en, this message translates to:
  /// **'Sticks'**
  String get sticks;

  /// No description provided for @disks.
  ///
  /// In en, this message translates to:
  /// **'Disks'**
  String get disks;

  /// No description provided for @tapes.
  ///
  /// In en, this message translates to:
  /// **'Tapes'**
  String get tapes;

  /// No description provided for @cartridges.
  ///
  /// In en, this message translates to:
  /// **'Cartridges'**
  String get cartridges;

  /// No description provided for @cassettes.
  ///
  /// In en, this message translates to:
  /// **'Cassettes'**
  String get cassettes;

  /// No description provided for @reels.
  ///
  /// In en, this message translates to:
  /// **'Reels'**
  String get reels;

  /// No description provided for @spools.
  ///
  /// In en, this message translates to:
  /// **'Spools'**
  String get spools;

  /// No description provided for @rolls.
  ///
  /// In en, this message translates to:
  /// **'Rolls'**
  String get rolls;

  /// No description provided for @sheets.
  ///
  /// In en, this message translates to:
  /// **'Sheets'**
  String get sheets;

  /// No description provided for @pages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get pages;

  /// No description provided for @books.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get books;

  /// No description provided for @magazines.
  ///
  /// In en, this message translates to:
  /// **'Magazines'**
  String get magazines;

  /// No description provided for @newspapers.
  ///
  /// In en, this message translates to:
  /// **'Newspapers'**
  String get newspapers;

  /// No description provided for @journals.
  ///
  /// In en, this message translates to:
  /// **'Journals'**
  String get journals;

  /// No description provided for @papers.
  ///
  /// In en, this message translates to:
  /// **'Papers'**
  String get papers;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @files.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get files;

  /// No description provided for @folders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get folders;

  /// No description provided for @directories.
  ///
  /// In en, this message translates to:
  /// **'Directories'**
  String get directories;

  /// No description provided for @paths.
  ///
  /// In en, this message translates to:
  /// **'Paths'**
  String get paths;

  /// No description provided for @routes.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get routes;

  /// No description provided for @ways.
  ///
  /// In en, this message translates to:
  /// **'Ways'**
  String get ways;

  /// No description provided for @streets.
  ///
  /// In en, this message translates to:
  /// **'Streets'**
  String get streets;

  /// No description provided for @roads.
  ///
  /// In en, this message translates to:
  /// **'Roads'**
  String get roads;

  /// No description provided for @highways.
  ///
  /// In en, this message translates to:
  /// **'Highways'**
  String get highways;

  /// No description provided for @freeways.
  ///
  /// In en, this message translates to:
  /// **'Freeways'**
  String get freeways;

  /// No description provided for @expressways.
  ///
  /// In en, this message translates to:
  /// **'Expressways'**
  String get expressways;

  /// No description provided for @parkways.
  ///
  /// In en, this message translates to:
  /// **'Parkways'**
  String get parkways;

  /// No description provided for @boulevards.
  ///
  /// In en, this message translates to:
  /// **'Boulevards'**
  String get boulevards;

  /// No description provided for @avenues.
  ///
  /// In en, this message translates to:
  /// **'Avenues'**
  String get avenues;

  /// No description provided for @lanes.
  ///
  /// In en, this message translates to:
  /// **'Lanes'**
  String get lanes;

  /// No description provided for @alleys.
  ///
  /// In en, this message translates to:
  /// **'Alleys'**
  String get alleys;

  /// No description provided for @courts.
  ///
  /// In en, this message translates to:
  /// **'Courts'**
  String get courts;

  /// No description provided for @squares.
  ///
  /// In en, this message translates to:
  /// **'Squares'**
  String get squares;

  /// No description provided for @circles.
  ///
  /// In en, this message translates to:
  /// **'Circles'**
  String get circles;

  /// No description provided for @rounds.
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get rounds;

  /// No description provided for @loops.
  ///
  /// In en, this message translates to:
  /// **'Loops'**
  String get loops;

  /// No description provided for @spirals.
  ///
  /// In en, this message translates to:
  /// **'Spirals'**
  String get spirals;

  /// No description provided for @curves.
  ///
  /// In en, this message translates to:
  /// **'Curves'**
  String get curves;

  /// No description provided for @bends.
  ///
  /// In en, this message translates to:
  /// **'Bends'**
  String get bends;

  /// No description provided for @turns.
  ///
  /// In en, this message translates to:
  /// **'Turns'**
  String get turns;

  /// No description provided for @corners.
  ///
  /// In en, this message translates to:
  /// **'Corners'**
  String get corners;

  /// No description provided for @angles.
  ///
  /// In en, this message translates to:
  /// **'Angles'**
  String get angles;

  /// No description provided for @edges.
  ///
  /// In en, this message translates to:
  /// **'Edges'**
  String get edges;

  /// No description provided for @sides.
  ///
  /// In en, this message translates to:
  /// **'Sides'**
  String get sides;

  /// No description provided for @faces.
  ///
  /// In en, this message translates to:
  /// **'Faces'**
  String get faces;

  /// No description provided for @surfaces.
  ///
  /// In en, this message translates to:
  /// **'Surfaces'**
  String get surfaces;

  /// No description provided for @planes.
  ///
  /// In en, this message translates to:
  /// **'Planes'**
  String get planes;

  /// No description provided for @levels.
  ///
  /// In en, this message translates to:
  /// **'Levels'**
  String get levels;

  /// No description provided for @floors.
  ///
  /// In en, this message translates to:
  /// **'Floors'**
  String get floors;

  /// No description provided for @stories.
  ///
  /// In en, this message translates to:
  /// **'Stories'**
  String get stories;

  /// No description provided for @tiers.
  ///
  /// In en, this message translates to:
  /// **'Tiers'**
  String get tiers;

  /// No description provided for @layers.
  ///
  /// In en, this message translates to:
  /// **'Layers'**
  String get layers;

  /// No description provided for @strata.
  ///
  /// In en, this message translates to:
  /// **'Strata'**
  String get strata;

  /// No description provided for @grades.
  ///
  /// In en, this message translates to:
  /// **'Grades'**
  String get grades;

  /// No description provided for @ranks.
  ///
  /// In en, this message translates to:
  /// **'Ranks'**
  String get ranks;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @kinds.
  ///
  /// In en, this message translates to:
  /// **'Kinds'**
  String get kinds;

  /// No description provided for @sorts.
  ///
  /// In en, this message translates to:
  /// **'Sorts'**
  String get sorts;

  /// No description provided for @varieties.
  ///
  /// In en, this message translates to:
  /// **'Varieties'**
  String get varieties;

  /// No description provided for @breeds.
  ///
  /// In en, this message translates to:
  /// **'Breeds'**
  String get breeds;

  /// No description provided for @species.
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get species;

  /// No description provided for @genera.
  ///
  /// In en, this message translates to:
  /// **'Genera'**
  String get genera;

  /// No description provided for @families.
  ///
  /// In en, this message translates to:
  /// **'Families'**
  String get families;

  /// No description provided for @phyla.
  ///
  /// In en, this message translates to:
  /// **'Phyla'**
  String get phyla;

  /// No description provided for @kingdoms.
  ///
  /// In en, this message translates to:
  /// **'Kingdoms'**
  String get kingdoms;

  /// No description provided for @domains.
  ///
  /// In en, this message translates to:
  /// **'Domains'**
  String get domains;

  /// No description provided for @realms.
  ///
  /// In en, this message translates to:
  /// **'Realms'**
  String get realms;

  /// No description provided for @worlds.
  ///
  /// In en, this message translates to:
  /// **'Worlds'**
  String get worlds;

  /// No description provided for @universes.
  ///
  /// In en, this message translates to:
  /// **'Universes'**
  String get universes;

  /// No description provided for @cosmos.
  ///
  /// In en, this message translates to:
  /// **'Cosmos'**
  String get cosmos;

  /// No description provided for @space.
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get space;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @matter.
  ///
  /// In en, this message translates to:
  /// **'Matter'**
  String get matter;

  /// No description provided for @energy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get energy;

  /// No description provided for @force.
  ///
  /// In en, this message translates to:
  /// **'Force'**
  String get force;

  /// No description provided for @power.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get power;

  /// No description provided for @strength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get strength;

  /// No description provided for @weakness.
  ///
  /// In en, this message translates to:
  /// **'Weakness'**
  String get weakness;

  /// No description provided for @advantage.
  ///
  /// In en, this message translates to:
  /// **'Advantage'**
  String get advantage;

  /// No description provided for @disadvantage.
  ///
  /// In en, this message translates to:
  /// **'Disadvantage'**
  String get disadvantage;

  /// No description provided for @benefit.
  ///
  /// In en, this message translates to:
  /// **'Benefit'**
  String get benefit;

  /// No description provided for @drawback.
  ///
  /// In en, this message translates to:
  /// **'Drawback'**
  String get drawback;

  /// No description provided for @pro.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get pro;

  /// No description provided for @con.
  ///
  /// In en, this message translates to:
  /// **'Con'**
  String get con;

  /// No description provided for @plus.
  ///
  /// In en, this message translates to:
  /// **'Plus'**
  String get plus;

  /// No description provided for @minus.
  ///
  /// In en, this message translates to:
  /// **'Minus'**
  String get minus;

  /// No description provided for @positive.
  ///
  /// In en, this message translates to:
  /// **'Positive'**
  String get positive;

  /// No description provided for @negative.
  ///
  /// In en, this message translates to:
  /// **'Negative'**
  String get negative;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @bad.
  ///
  /// In en, this message translates to:
  /// **'Bad'**
  String get bad;

  /// No description provided for @better.
  ///
  /// In en, this message translates to:
  /// **'Better'**
  String get better;

  /// No description provided for @worse.
  ///
  /// In en, this message translates to:
  /// **'Worse'**
  String get worse;

  /// No description provided for @best.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get best;

  /// No description provided for @worst.
  ///
  /// In en, this message translates to:
  /// **'Worst'**
  String get worst;

  /// No description provided for @optimal.
  ///
  /// In en, this message translates to:
  /// **'Optimal'**
  String get optimal;

  /// No description provided for @suboptimal.
  ///
  /// In en, this message translates to:
  /// **'Suboptimal'**
  String get suboptimal;

  /// No description provided for @perfect.
  ///
  /// In en, this message translates to:
  /// **'Perfect'**
  String get perfect;

  /// No description provided for @imperfect.
  ///
  /// In en, this message translates to:
  /// **'Imperfect'**
  String get imperfect;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @incomplete.
  ///
  /// In en, this message translates to:
  /// **'Incomplete'**
  String get incomplete;

  /// No description provided for @finished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get finished;

  /// No description provided for @unfinished.
  ///
  /// In en, this message translates to:
  /// **'Unfinished'**
  String get unfinished;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @undone.
  ///
  /// In en, this message translates to:
  /// **'Undone'**
  String get undone;

  /// No description provided for @accomplished.
  ///
  /// In en, this message translates to:
  /// **'Accomplished'**
  String get accomplished;

  /// No description provided for @unaccomplished.
  ///
  /// In en, this message translates to:
  /// **'Unaccomplished'**
  String get unaccomplished;

  /// No description provided for @achieved.
  ///
  /// In en, this message translates to:
  /// **'Achieved'**
  String get achieved;

  /// No description provided for @unachieved.
  ///
  /// In en, this message translates to:
  /// **'Unachieved'**
  String get unachieved;

  /// No description provided for @attained.
  ///
  /// In en, this message translates to:
  /// **'Attained'**
  String get attained;

  /// No description provided for @unattained.
  ///
  /// In en, this message translates to:
  /// **'Unattained'**
  String get unattained;

  /// No description provided for @reached.
  ///
  /// In en, this message translates to:
  /// **'Reached'**
  String get reached;

  /// No description provided for @unreached.
  ///
  /// In en, this message translates to:
  /// **'Unreached'**
  String get unreached;

  /// No description provided for @gained.
  ///
  /// In en, this message translates to:
  /// **'Gained'**
  String get gained;

  /// No description provided for @lost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get lost;

  /// No description provided for @won.
  ///
  /// In en, this message translates to:
  /// **'Won'**
  String get won;

  /// No description provided for @earned.
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get earned;

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @wasted.
  ///
  /// In en, this message translates to:
  /// **'Wasted'**
  String get wasted;

  /// No description provided for @used.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get used;

  /// No description provided for @unused.
  ///
  /// In en, this message translates to:
  /// **'Unused'**
  String get unused;

  /// No description provided for @consumed.
  ///
  /// In en, this message translates to:
  /// **'Consumed'**
  String get consumed;

  /// No description provided for @unconsumed.
  ///
  /// In en, this message translates to:
  /// **'Unconsumed'**
  String get unconsumed;

  /// No description provided for @depleted.
  ///
  /// In en, this message translates to:
  /// **'Depleted'**
  String get depleted;

  /// No description provided for @replenished.
  ///
  /// In en, this message translates to:
  /// **'Replenished'**
  String get replenished;

  /// No description provided for @filled.
  ///
  /// In en, this message translates to:
  /// **'Filled'**
  String get filled;

  /// No description provided for @empty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get empty;

  /// No description provided for @full.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get full;

  /// No description provided for @partial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get partial;

  /// No description provided for @whole.
  ///
  /// In en, this message translates to:
  /// **'Whole'**
  String get whole;

  /// No description provided for @fractional.
  ///
  /// In en, this message translates to:
  /// **'Fractional'**
  String get fractional;

  /// No description provided for @integral.
  ///
  /// In en, this message translates to:
  /// **'Integral'**
  String get integral;

  /// No description provided for @decimal.
  ///
  /// In en, this message translates to:
  /// **'Decimal'**
  String get decimal;

  /// No description provided for @binary.
  ///
  /// In en, this message translates to:
  /// **'Binary'**
  String get binary;

  /// No description provided for @hexadecimal.
  ///
  /// In en, this message translates to:
  /// **'Hexadecimal'**
  String get hexadecimal;

  /// No description provided for @octal.
  ///
  /// In en, this message translates to:
  /// **'Octal'**
  String get octal;

  /// No description provided for @base.
  ///
  /// In en, this message translates to:
  /// **'Base'**
  String get base;

  /// No description provided for @radix.
  ///
  /// In en, this message translates to:
  /// **'Radix'**
  String get radix;

  /// No description provided for @exponent.
  ///
  /// In en, this message translates to:
  /// **'Exponent'**
  String get exponent;

  /// No description provided for @mantissa.
  ///
  /// In en, this message translates to:
  /// **'Mantissa'**
  String get mantissa;

  /// No description provided for @significand.
  ///
  /// In en, this message translates to:
  /// **'Significand'**
  String get significand;

  /// No description provided for @characteristic.
  ///
  /// In en, this message translates to:
  /// **'Characteristic'**
  String get characteristic;

  /// No description provided for @logarithm.
  ///
  /// In en, this message translates to:
  /// **'Logarithm'**
  String get logarithm;

  /// No description provided for @antilogarithm.
  ///
  /// In en, this message translates to:
  /// **'Antilogarithm'**
  String get antilogarithm;

  /// No description provided for @natural.
  ///
  /// In en, this message translates to:
  /// **'Natural'**
  String get natural;

  /// No description provided for @common.
  ///
  /// In en, this message translates to:
  /// **'Common'**
  String get common;

  /// No description provided for @newPost.
  ///
  /// In en, this message translates to:
  /// **'New post'**
  String get newPost;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @tryOtherFilters.
  ///
  /// In en, this message translates to:
  /// **'Try other filters or create your first listing!'**
  String get tryOtherFilters;

  /// No description provided for @firstListing.
  ///
  /// In en, this message translates to:
  /// **'Create first listing'**
  String get firstListing;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search results'**
  String get searchResults;

  /// No description provided for @searchResultsFor.
  ///
  /// In en, this message translates to:
  /// **'Search: \"{query}\"'**
  String searchResultsFor(Object query);

  /// No description provided for @resultsInRadius.
  ///
  /// In en, this message translates to:
  /// **'{count} results in {radius} km radius'**
  String resultsInRadius(Object count, Object radius);

  /// No description provided for @searchError.
  ///
  /// In en, this message translates to:
  /// **'Search error'**
  String get searchError;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noSearchResults;

  /// No description provided for @tryOtherKeywords.
  ///
  /// In en, this message translates to:
  /// **'Try other keywords or expand the search radius'**
  String get tryOtherKeywords;

  /// No description provided for @radiusSettings.
  ///
  /// In en, this message translates to:
  /// **'Set search radius'**
  String get radiusSettings;

  /// No description provided for @currentRadius.
  ///
  /// In en, this message translates to:
  /// **'Current radius: {radius} km'**
  String currentRadius(Object radius);

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @searchDialog.
  ///
  /// In en, this message translates to:
  /// **'Search items'**
  String get searchDialog;

  /// No description provided for @searchTerm.
  ///
  /// In en, this message translates to:
  /// **'Search term'**
  String get searchTerm;

  /// No description provided for @searchHintText.
  ///
  /// In en, this message translates to:
  /// **'e.g. pants, chain, book...'**
  String get searchHintText;

  /// No description provided for @searchInRadius.
  ///
  /// In en, this message translates to:
  /// **'Search in radius of {radius} km'**
  String searchInRadius(Object radius);

  /// No description provided for @refreshSearch.
  ///
  /// In en, this message translates to:
  /// **'Refresh search'**
  String get refreshSearch;

  /// No description provided for @contactSeller.
  ///
  /// In en, this message translates to:
  /// **'Contact seller'**
  String get contactSeller;

  /// No description provided for @contactBuyer.
  ///
  /// In en, this message translates to:
  /// **'Contact buyer'**
  String get contactBuyer;

  /// No description provided for @startChat.
  ///
  /// In en, this message translates to:
  /// **'Start chat'**
  String get startChat;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get sendMessage;

  /// No description provided for @messageSent.
  ///
  /// In en, this message translates to:
  /// **'Message sent'**
  String get messageSent;

  /// No description provided for @messageError.
  ///
  /// In en, this message translates to:
  /// **'Error sending message'**
  String get messageError;

  /// No description provided for @likeItem.
  ///
  /// In en, this message translates to:
  /// **'Like item'**
  String get likeItem;

  /// No description provided for @unlikeItem.
  ///
  /// In en, this message translates to:
  /// **'Unlike item'**
  String get unlikeItem;

  /// No description provided for @itemLiked.
  ///
  /// In en, this message translates to:
  /// **'{title} was liked!'**
  String itemLiked(Object title);

  /// No description provided for @itemUnliked.
  ///
  /// In en, this message translates to:
  /// **'{title} was unliked'**
  String itemUnliked(Object title);

  /// No description provided for @likeError.
  ///
  /// In en, this message translates to:
  /// **'Error liking'**
  String get likeError;

  /// No description provided for @unlikeError.
  ///
  /// In en, this message translates to:
  /// **'Error unliking'**
  String get unlikeError;

  /// No description provided for @pleaseLogin.
  ///
  /// In en, this message translates to:
  /// **'Please log in to see items'**
  String get pleaseLogin;

  /// No description provided for @pleaseLoginToSeeListings.
  ///
  /// In en, this message translates to:
  /// **'Please login to see listings'**
  String get pleaseLoginToSeeListings;

  /// No description provided for @pleaseLoginToLike.
  ///
  /// In en, this message translates to:
  /// **'Please log in to like items'**
  String get pleaseLoginToLike;

  /// No description provided for @loadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading items'**
  String get loadError;

  /// No description provided for @loadListingsError.
  ///
  /// In en, this message translates to:
  /// **'Error loading items: {error}'**
  String loadListingsError(Object error);

  /// No description provided for @noArticlesFound.
  ///
  /// In en, this message translates to:
  /// **'No articles found'**
  String get noArticlesFound;

  /// No description provided for @articlesNearby.
  ///
  /// In en, this message translates to:
  /// **'Articles nearby ({radius} km)'**
  String articlesNearby(Object radius);

  /// No description provided for @filterButton.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filterButton;

  /// No description provided for @radiusIcon.
  ///
  /// In en, this message translates to:
  /// **'Set radius'**
  String get radiusIcon;

  /// No description provided for @searchIcon.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchIcon;

  /// No description provided for @addIcon.
  ///
  /// In en, this message translates to:
  /// **'Create listing'**
  String get addIcon;

  /// No description provided for @refreshIcon.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshIcon;

  /// No description provided for @settingsIcon.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsIcon;

  /// No description provided for @profileIcon.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileIcon;

  /// No description provided for @editIcon.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editIcon;

  /// No description provided for @deleteIcon.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteIcon;

  /// No description provided for @shareIcon.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareIcon;

  /// No description provided for @likeIcon.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get likeIcon;

  /// No description provided for @unlikeIcon.
  ///
  /// In en, this message translates to:
  /// **'Unlike'**
  String get unlikeIcon;

  /// No description provided for @chatIcon.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatIcon;

  /// No description provided for @messageIcon.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messageIcon;

  /// No description provided for @locationIcon.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationIcon;

  /// No description provided for @cameraIcon.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraIcon;

  /// No description provided for @galleryIcon.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get galleryIcon;

  /// No description provided for @imageIcon.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get imageIcon;

  /// No description provided for @priceIcon.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceIcon;

  /// No description provided for @categoryIcon.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryIcon;

  /// No description provided for @conditionIcon.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get conditionIcon;

  /// No description provided for @descriptionIcon.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionIcon;

  /// No description provided for @titleIcon.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleIcon;

  /// No description provided for @userIcon.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userIcon;

  /// No description provided for @storeIcon.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get storeIcon;

  /// No description provided for @communityIcon.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get communityIcon;

  /// No description provided for @groupIcon.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get groupIcon;

  /// No description provided for @membersIcon.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get membersIcon;

  /// No description provided for @adminIcon.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get adminIcon;

  /// No description provided for @moderatorIcon.
  ///
  /// In en, this message translates to:
  /// **'Moderator'**
  String get moderatorIcon;

  /// No description provided for @memberIcon.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get memberIcon;

  /// No description provided for @inviteIcon.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get inviteIcon;

  /// No description provided for @leaveIcon.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leaveIcon;

  /// No description provided for @joinIcon.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get joinIcon;

  /// No description provided for @createIcon.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createIcon;

  /// No description provided for @saveIcon.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveIcon;

  /// No description provided for @cancelIcon.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelIcon;

  /// No description provided for @confirmIcon.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmIcon;

  /// No description provided for @backIcon.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backIcon;

  /// No description provided for @nextIcon.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextIcon;

  /// No description provided for @doneIcon.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneIcon;

  /// No description provided for @loadingIcon.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingIcon;

  /// No description provided for @errorIcon.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorIcon;

  /// No description provided for @successIcon.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get successIcon;

  /// No description provided for @warningIcon.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warningIcon;

  /// No description provided for @infoIcon.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get infoIcon;

  /// No description provided for @closeIcon.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeIcon;

  /// No description provided for @okIcon.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okIcon;

  /// No description provided for @yesIcon.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yesIcon;

  /// No description provided for @noIcon.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get noIcon;

  /// Title for premium features section
  ///
  /// In en, this message translates to:
  /// **'Premium Features'**
  String get premiumFeatures;

  /// No description provided for @store.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get store;

  /// No description provided for @myStores.
  ///
  /// In en, this message translates to:
  /// **'My Stores'**
  String get myStores;

  /// No description provided for @createStore.
  ///
  /// In en, this message translates to:
  /// **'Create Store'**
  String get createStore;

  /// No description provided for @storeType.
  ///
  /// In en, this message translates to:
  /// **'Store Type'**
  String get storeType;

  /// No description provided for @storeTypeDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the store type that best fits your needs.'**
  String get storeTypeDescription;

  /// No description provided for @privateFleaMarket.
  ///
  /// In en, this message translates to:
  /// **'Second-Hand Dealer'**
  String get privateFleaMarket;

  /// No description provided for @privateFleaMarketDescription.
  ///
  /// In en, this message translates to:
  /// **'For individuals selling used items (similar to a private flea market).'**
  String get privateFleaMarketDescription;

  /// No description provided for @smallStore.
  ///
  /// In en, this message translates to:
  /// **'Small Store (Hobby / Handmade)'**
  String get smallStore;

  /// No description provided for @smallStoreDescription.
  ///
  /// In en, this message translates to:
  /// **'For creative products like jewelry, decor, DIY - also as a side income.'**
  String get smallStoreDescription;

  /// No description provided for @professionalStore.
  ///
  /// In en, this message translates to:
  /// **'Professional Store'**
  String get professionalStore;

  /// No description provided for @professionalStoreDescription.
  ///
  /// In en, this message translates to:
  /// **'For regular or commercial providers with higher needs.'**
  String get professionalStoreDescription;

  /// No description provided for @storeConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Configure Store'**
  String get storeConfiguration;

  /// No description provided for @storeConfigurationDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the basic information for your store.'**
  String get storeConfigurationDescription;

  /// No description provided for @storeLogo.
  ///
  /// In en, this message translates to:
  /// **'Store Logo'**
  String get storeLogo;

  /// No description provided for @storeName.
  ///
  /// In en, this message translates to:
  /// **'Store Name'**
  String get storeName;

  /// No description provided for @storeDescription.
  ///
  /// In en, this message translates to:
  /// **'Store Description'**
  String get storeDescription;

  /// No description provided for @storeNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. My Second-Hand Boutique'**
  String get storeNameHint;

  /// No description provided for @storeDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your store and what you offer...'**
  String get storeDescriptionHint;

  /// No description provided for @storeCreated.
  ///
  /// In en, this message translates to:
  /// **'Store created successfully!'**
  String get storeCreated;

  /// No description provided for @storeCreating.
  ///
  /// In en, this message translates to:
  /// **'Creating store...'**
  String get storeCreating;

  /// No description provided for @storeError.
  ///
  /// In en, this message translates to:
  /// **'Error creating store'**
  String get storeError;

  /// No description provided for @noStoreYet.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have a store yet'**
  String get noStoreYet;

  /// No description provided for @noStoreDescription.
  ///
  /// In en, this message translates to:
  /// **'Create your own store and sell unlimited!'**
  String get noStoreDescription;

  /// No description provided for @storeFeatures.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get storeFeatures;

  /// No description provided for @storePrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get storePrice;

  /// No description provided for @storeFeaturesBasic.
  ///
  /// In en, this message translates to:
  /// **'Simple store, Basic functions, Minimal price'**
  String get storeFeaturesBasic;

  /// No description provided for @storeFeaturesSmall.
  ///
  /// In en, this message translates to:
  /// **'Custom design (Logo, colors, text), Creative products, Side income possible'**
  String get storeFeaturesSmall;

  /// No description provided for @storeFeaturesProfessional.
  ///
  /// In en, this message translates to:
  /// **'Advanced features, Radius advertising, Statistics, Commercial use'**
  String get storeFeaturesProfessional;

  /// No description provided for @storePriceFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get storePriceFree;

  /// No description provided for @storePriceSmall.
  ///
  /// In en, this message translates to:
  /// **'Small price'**
  String get storePriceSmall;

  /// No description provided for @storePriceSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription model'**
  String get storePriceSubscription;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethod;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment methods'**
  String get paymentMethods;

  /// No description provided for @creditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get creditCard;

  /// No description provided for @applePay.
  ///
  /// In en, this message translates to:
  /// **'Apple Pay'**
  String get applePay;

  /// No description provided for @twint.
  ///
  /// In en, this message translates to:
  /// **'Twint'**
  String get twint;

  /// No description provided for @paypal.
  ///
  /// In en, this message translates to:
  /// **'PayPal'**
  String get paypal;

  /// No description provided for @stripe.
  ///
  /// In en, this message translates to:
  /// **'Stripe'**
  String get stripe;

  /// No description provided for @payrexx.
  ///
  /// In en, this message translates to:
  /// **'Payrexx'**
  String get payrexx;

  /// No description provided for @paymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Payment amount'**
  String get paymentAmount;

  /// No description provided for @paymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Payment status'**
  String get paymentStatus;

  /// No description provided for @paymentCompleted.
  ///
  /// In en, this message translates to:
  /// **'Payment completed'**
  String get paymentCompleted;

  /// No description provided for @paymentPending.
  ///
  /// In en, this message translates to:
  /// **'Payment pending'**
  String get paymentPending;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get paymentFailed;

  /// No description provided for @paymentRefunded.
  ///
  /// In en, this message translates to:
  /// **'Payment refunded'**
  String get paymentRefunded;

  /// No description provided for @paymentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Payment cancelled'**
  String get paymentCancelled;

  /// No description provided for @paymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment history'**
  String get paymentHistory;

  /// No description provided for @paymentReceipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get paymentReceipt;

  /// No description provided for @paymentDate.
  ///
  /// In en, this message translates to:
  /// **'Payment date'**
  String get paymentDate;

  /// No description provided for @paymentType.
  ///
  /// In en, this message translates to:
  /// **'Payment type'**
  String get paymentType;

  /// No description provided for @premiumMonthly.
  ///
  /// In en, this message translates to:
  /// **'Premium Month'**
  String get premiumMonthly;

  /// No description provided for @premiumYearly.
  ///
  /// In en, this message translates to:
  /// **'Premium Year'**
  String get premiumYearly;

  /// No description provided for @addonSwaps5.
  ///
  /// In en, this message translates to:
  /// **'+5 Swaps'**
  String get addonSwaps5;

  /// No description provided for @addonSells5.
  ///
  /// In en, this message translates to:
  /// **'+5 Sells'**
  String get addonSells5;

  /// No description provided for @premiumMonthlyPrice.
  ///
  /// In en, this message translates to:
  /// **'CHF 5'**
  String get premiumMonthlyPrice;

  /// No description provided for @premiumYearlyPrice.
  ///
  /// In en, this message translates to:
  /// **'CHF 54'**
  String get premiumYearlyPrice;

  /// No description provided for @addonSwaps5Price.
  ///
  /// In en, this message translates to:
  /// **'CHF 1'**
  String get addonSwaps5Price;

  /// No description provided for @addonSells5Price.
  ///
  /// In en, this message translates to:
  /// **'CHF 1'**
  String get addonSells5Price;

  /// No description provided for @premiumMonthlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Swap&Shop Premium - Monthly Subscription'**
  String get premiumMonthlyTitle;

  /// No description provided for @premiumYearlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Swap&Shop Premium - Yearly Subscription'**
  String get premiumYearlyTitle;

  /// No description provided for @addonSwaps5Title.
  ///
  /// In en, this message translates to:
  /// **'Swap&Shop +5 Swaps'**
  String get addonSwaps5Title;

  /// No description provided for @addonSells5Title.
  ///
  /// In en, this message translates to:
  /// **'Swap&Shop +5 Sells'**
  String get addonSells5Title;

  /// No description provided for @premiumMonthlyDescription.
  ///
  /// In en, this message translates to:
  /// **'Unlimited swaps and sells for 1 month'**
  String get premiumMonthlyDescription;

  /// No description provided for @premiumYearlyDescription.
  ///
  /// In en, this message translates to:
  /// **'Unlimited swaps and sells for 1 year'**
  String get premiumYearlyDescription;

  /// No description provided for @addonSwaps5Description.
  ///
  /// In en, this message translates to:
  /// **'5 additional swaps - 50% donation / 50% development'**
  String get addonSwaps5Description;

  /// No description provided for @addonSells5Description.
  ///
  /// In en, this message translates to:
  /// **'5 additional sells - 50% donation / 50% development'**
  String get addonSells5Description;

  /// No description provided for @addonDonationText.
  ///
  /// In en, this message translates to:
  /// **'50% of your payment will be donated – 50% goes to app development.'**
  String get addonDonationText;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @purchaseAddon.
  ///
  /// In en, this message translates to:
  /// **'Purchase Add-on'**
  String get purchaseAddon;

  /// No description provided for @selectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Select payment method'**
  String get selectPaymentMethod;

  /// No description provided for @confirmPayment.
  ///
  /// In en, this message translates to:
  /// **'Confirm payment'**
  String get confirmPayment;

  /// No description provided for @processingPayment.
  ///
  /// In en, this message translates to:
  /// **'Processing payment...'**
  String get processingPayment;

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment successful!'**
  String get paymentSuccessful;

  /// No description provided for @paymentError.
  ///
  /// In en, this message translates to:
  /// **'Payment error'**
  String get paymentError;

  /// No description provided for @insufficientFunds.
  ///
  /// In en, this message translates to:
  /// **'Insufficient funds'**
  String get insufficientFunds;

  /// No description provided for @cardDeclined.
  ///
  /// In en, this message translates to:
  /// **'Card declined'**
  String get cardDeclined;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get networkError;

  /// No description provided for @limits.
  ///
  /// In en, this message translates to:
  /// **'Limits'**
  String get limits;

  /// No description provided for @freeLimits.
  ///
  /// In en, this message translates to:
  /// **'Free limits'**
  String get freeLimits;

  /// No description provided for @premiumLimits.
  ///
  /// In en, this message translates to:
  /// **'Premium limits'**
  String get premiumLimits;

  /// No description provided for @swapsUsed.
  ///
  /// In en, this message translates to:
  /// **'Swaps used'**
  String get swapsUsed;

  /// No description provided for @sellsUsed.
  ///
  /// In en, this message translates to:
  /// **'Sells used'**
  String get sellsUsed;

  /// No description provided for @swapsRemaining.
  ///
  /// In en, this message translates to:
  /// **'Swaps remaining'**
  String get swapsRemaining;

  /// No description provided for @sellsRemaining.
  ///
  /// In en, this message translates to:
  /// **'Sells remaining'**
  String get sellsRemaining;

  /// No description provided for @addonSwapsRemaining.
  ///
  /// In en, this message translates to:
  /// **'Add-on swaps remaining'**
  String get addonSwapsRemaining;

  /// No description provided for @addonSellsRemaining.
  ///
  /// In en, this message translates to:
  /// **'Add-on sells remaining'**
  String get addonSellsRemaining;

  /// No description provided for @maxFreeSwaps.
  ///
  /// In en, this message translates to:
  /// **'Max free swaps'**
  String get maxFreeSwaps;

  /// No description provided for @maxFreeSells.
  ///
  /// In en, this message translates to:
  /// **'Max free sells'**
  String get maxFreeSells;

  /// No description provided for @maxFreeGiveaways.
  ///
  /// In en, this message translates to:
  /// **'Max free giveaways'**
  String get maxFreeGiveaways;

  /// No description provided for @limitReached.
  ///
  /// In en, this message translates to:
  /// **'Limit reached'**
  String get limitReached;

  /// No description provided for @swapLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You have reached your free swap limit'**
  String get swapLimitReached;

  /// No description provided for @sellLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You have reached your free sell limit'**
  String get sellLimitReached;

  /// No description provided for @giveawayLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You have reached your free giveaway limit'**
  String get giveawayLimitReached;

  /// No description provided for @limitDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Limit reached'**
  String get limitDialogTitle;

  /// No description provided for @limitDialogDescription.
  ///
  /// In en, this message translates to:
  /// **'You have reached your free limit for this month.'**
  String get limitDialogDescription;

  /// No description provided for @limitDialogPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium for unlimited usage'**
  String get limitDialogPremium;

  /// No description provided for @limitDialogAddon.
  ///
  /// In en, this message translates to:
  /// **'Or purchase an add-on for additional usage'**
  String get limitDialogAddon;

  /// No description provided for @limitDialogContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue with free limits'**
  String get limitDialogContinue;

  /// No description provided for @limitDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get limitDialogCancel;

  /// No description provided for @limitDialogUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get limitDialogUpgrade;

  /// No description provided for @limitDialogPurchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get limitDialogPurchase;

  /// No description provided for @limitDialogInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get limitDialogInfo;

  /// No description provided for @limitDialogInfoText.
  ///
  /// In en, this message translates to:
  /// **'Your limits are automatically reset every month.'**
  String get limitDialogInfoText;

  /// No description provided for @limitDialogInfoTextPremium.
  ///
  /// In en, this message translates to:
  /// **'With Premium you have unlimited usage.'**
  String get limitDialogInfoTextPremium;

  /// No description provided for @limitDialogInfoTextAddon.
  ///
  /// In en, this message translates to:
  /// **'Add-ons give you additional usage for the current month.'**
  String get limitDialogInfoTextAddon;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'fr', 'it', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
