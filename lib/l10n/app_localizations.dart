import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('en'),
    Locale('id'),
  ];

  /// Bottom navigation tab: home feed.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navigationHome;

  /// Bottom navigation tab: game discovery.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get navigationDiscover;

  /// Bottom navigation tab: play hub.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get navigationPlay;

  /// Bottom navigation tab: missions.
  ///
  /// In en, this message translates to:
  /// **'Missions'**
  String get navigationMissions;

  /// Bottom navigation tab: profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navigationProfile;

  /// Button that retries a failed request.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonRetry;

  /// Dialog button that dismisses without changes.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Destructive confirmation button.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// Button that opens or submits sign in.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get commonSignIn;

  /// Button that opens registration.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get commonCreateAccount;

  /// Accessible label while content loads.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get commonLoading;

  /// Tooltip for the back navigation button.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// Button that moves to the next step.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// Button that skips an optional flow.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// Link that opens the full list of a section.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get commonSeeAll;

  /// Placeholder of the game search field.
  ///
  /// In en, this message translates to:
  /// **'Search games...'**
  String get commonSearchGames;

  /// Tooltip of the button that clears the search field.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get commonClearSearch;

  /// Badge on games that are ready for phones.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get commonMobileBadge;

  /// Badge on menu items that are not available yet.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get commonSoon;

  /// Button that signs the player out.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get commonSignOut;

  /// Title of the account settings screen.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get settingsTitle;

  /// Section title for the app language selector.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Helper text under the language section title.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get settingsLanguageSubtitle;

  /// Language option that follows the device language.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsSystemDefault;

  /// Native name of English. Keep in English in every locale.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsEnglish;

  /// Native name of Indonesian. Keep in Indonesian in every locale.
  ///
  /// In en, this message translates to:
  /// **'Bahasa Indonesia'**
  String get settingsIndonesian;

  /// Confirmation shown after the language changes, in the new language.
  ///
  /// In en, this message translates to:
  /// **'Language updated'**
  String get settingsLanguageChanged;

  /// Title shown to guests on the account settings screen.
  ///
  /// In en, this message translates to:
  /// **'Manage your account'**
  String get settingsManageAccountTitle;

  /// Message shown to guests on the account settings screen.
  ///
  /// In en, this message translates to:
  /// **'Sign in to view and manage your account.'**
  String get settingsManageAccountMessage;

  /// Label of the player's display name.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get settingsDisplayName;

  /// Label of the player's @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get settingsUsername;

  /// Label of the player's email address.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get settingsEmail;

  /// Helper under the display name field.
  ///
  /// In en, this message translates to:
  /// **'The name other people see. 2–40 characters.'**
  String get settingsDisplayNameHint;

  /// Error when the display name fails validation.
  ///
  /// In en, this message translates to:
  /// **'Use 2–40 characters.'**
  String get settingsDisplayNameInvalid;

  /// Helper under the username field.
  ///
  /// In en, this message translates to:
  /// **'Letters, numbers, or hyphens. 3–30 characters.'**
  String get settingsUsernameHint;

  /// Error when the username fails validation.
  ///
  /// In en, this message translates to:
  /// **'Use 3–30 letters, numbers, or hyphens.'**
  String get settingsUsernameInvalid;

  /// Error when another account already uses the username.
  ///
  /// In en, this message translates to:
  /// **'That username is already taken.'**
  String get settingsUsernameTaken;

  /// Button that saves the display name and username.
  ///
  /// In en, this message translates to:
  /// **'Save profile'**
  String get settingsSave;

  /// Button label while the profile is saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get settingsSaving;

  /// Confirmation after the display name or username is saved.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get settingsProfileSaved;

  /// Section title for privacy toggles.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacy;

  /// Privacy toggle title.
  ///
  /// In en, this message translates to:
  /// **'Show favorites'**
  String get settingsPrivacyShowFavorites;

  /// Privacy toggle explanation.
  ///
  /// In en, this message translates to:
  /// **'Others can see games you saved.'**
  String get settingsPrivacyShowFavoritesHint;

  /// Privacy toggle title.
  ///
  /// In en, this message translates to:
  /// **'Show play history'**
  String get settingsPrivacyShowHistory;

  /// Privacy toggle explanation.
  ///
  /// In en, this message translates to:
  /// **'Others can see what you played recently.'**
  String get settingsPrivacyShowHistoryHint;

  /// Privacy toggle title.
  ///
  /// In en, this message translates to:
  /// **'Show achievements'**
  String get settingsPrivacyShowAchievements;

  /// Privacy toggle explanation.
  ///
  /// In en, this message translates to:
  /// **'Others can see badges you unlocked.'**
  String get settingsPrivacyShowAchievementsHint;

  /// Privacy toggle title.
  ///
  /// In en, this message translates to:
  /// **'Show activity'**
  String get settingsPrivacyShowActivity;

  /// Privacy toggle explanation.
  ///
  /// In en, this message translates to:
  /// **'Your activity appears in the community feed.'**
  String get settingsPrivacyShowActivityHint;

  /// Privacy toggle title.
  ///
  /// In en, this message translates to:
  /// **'Show on leaderboards'**
  String get settingsPrivacyShowOnLeaderboards;

  /// Privacy toggle explanation.
  ///
  /// In en, this message translates to:
  /// **'Your rank is visible on public leaderboards.'**
  String get settingsPrivacyShowOnLeaderboardsHint;

  /// Title of the sign in screen.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authLoginTitle;

  /// Subtitle of the sign in screen.
  ///
  /// In en, this message translates to:
  /// **'Sign in to keep your XP, streak and achievements.'**
  String get authLoginSubtitle;

  /// Title of the registration screen.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get authRegisterTitle;

  /// Subtitle of the registration screen.
  ///
  /// In en, this message translates to:
  /// **'Earn XP, unlock achievements and compete with players.'**
  String get authRegisterSubtitle;

  /// Primary button that submits registration.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authCreateAccount;

  /// Placeholder of the email field.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailHint;

  /// Placeholder of the password field.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordHint;

  /// Placeholder of the display name field.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get authDisplayNameHint;

  /// Tooltip that reveals the password.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// Tooltip that hides the password.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// Validation error for an empty email.
  ///
  /// In en, this message translates to:
  /// **'Email is required.'**
  String get authEmailRequired;

  /// Validation error for a malformed email.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email.'**
  String get authEmailInvalid;

  /// Validation error for an empty password.
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get authPasswordRequired;

  /// Validation error for a value that is too short.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Use at least 1 character.} other{Use at least {count} characters.}}'**
  String authMinCharacters(int count);

  /// Sign in error for wrong credentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get authInvalidCredentials;

  /// Registration error for a duplicate email.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists.'**
  String get authEmailTaken;

  /// Link from sign in to registration.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Create one'**
  String get authNoAccount;

  /// Link from registration to sign in.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get authHaveAccount;

  /// Onboarding slide 1 headline, word 1 of 3.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get onboardingSlide1Word1;

  /// Onboarding slide 1 headline, highlighted word 2 of 3.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get onboardingSlide1Word2;

  /// Onboarding slide 1 headline, word 3 of 3.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get onboardingSlide1Word3;

  /// Onboarding slide 1 body.
  ///
  /// In en, this message translates to:
  /// **'Thousands of instant games picked for you. No downloads, just tap and play.'**
  String get onboardingSlide1Body;

  /// Onboarding slide 2 headline, word 1 of 3.
  ///
  /// In en, this message translates to:
  /// **'Earn'**
  String get onboardingSlide2Word1;

  /// Onboarding slide 2 headline, highlighted word 2 of 3.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get onboardingSlide2Word2;

  /// Onboarding slide 2 headline, word 3 of 3.
  ///
  /// In en, this message translates to:
  /// **'Compete'**
  String get onboardingSlide2Word3;

  /// Onboarding slide 2 body.
  ///
  /// In en, this message translates to:
  /// **'Earn XP every time you play, complete daily missions, build your streak and climb the leaderboard.'**
  String get onboardingSlide2Body;

  /// Onboarding slide 3 headline, word 1 of 3.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get onboardingSlide3Word1;

  /// Onboarding slide 3 headline, highlighted word 2 of 3.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get onboardingSlide3Word2;

  /// Onboarding slide 3 headline, word 3 of 3.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get onboardingSlide3Word3;

  /// Onboarding slide 3 body.
  ///
  /// In en, this message translates to:
  /// **'Join a community of gamers, discover new games, earn rewards, and make new friends!'**
  String get onboardingSlide3Body;

  /// Button on the last onboarding slide.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// Link on the last onboarding slide that opens sign in.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get onboardingHaveAccount;

  /// Accessibility label of the onboarding page dots.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {count}'**
  String onboardingPageIndicator(int page, int count);

  /// Relative time for less than a minute ago.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get timeJustNow;

  /// Compact relative time in minutes.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String timeMinutesAgo(int count);

  /// Compact relative time in hours.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String timeHoursAgo(int count);

  /// Compact relative time in days.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String timeDaysAgo(int count);

  /// Compact duration part in days.
  ///
  /// In en, this message translates to:
  /// **'{count}d'**
  String timeDays(int count);

  /// Compact duration part in hours.
  ///
  /// In en, this message translates to:
  /// **'{count}h'**
  String timeHours(int count);

  /// Compact duration part in minutes.
  ///
  /// In en, this message translates to:
  /// **'{count}m'**
  String timeMinutes(int count);

  /// Duration shorter than one minute.
  ///
  /// In en, this message translates to:
  /// **'<1m'**
  String get timeUnderMinute;

  /// Time remaining, e.g. '2d 5h left'.
  ///
  /// In en, this message translates to:
  /// **'{time} left'**
  String timeLeft(String time);

  /// Shown when a deadline has passed.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get timeExpired;

  /// Network error message.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline or the connection is unstable. Please try again.'**
  String get errorOffline;

  /// HTTP 401 error message.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get errorSessionExpired;

  /// HTTP 403 error message.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have access to this content.'**
  String get errorForbidden;

  /// HTTP 404 error message.
  ///
  /// In en, this message translates to:
  /// **'Content not found.'**
  String get errorNotFound;

  /// HTTP 429 error message.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please try again shortly.'**
  String get errorTooManyRequests;

  /// HTTP 5xx error message.
  ///
  /// In en, this message translates to:
  /// **'Our servers are having trouble. Please try again later.'**
  String get errorServer;

  /// Fallback error message.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// Action that marks every notification as read.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notificationsMarkAllRead;

  /// Notifications title for guests.
  ///
  /// In en, this message translates to:
  /// **'Stay in the loop'**
  String get notificationsSignInTitle;

  /// Notifications message for guests.
  ///
  /// In en, this message translates to:
  /// **'Sign in to get updates on achievements, missions and replies.'**
  String get notificationsSignInMessage;

  /// Empty notifications state.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up.'**
  String get notificationsEmpty;

  /// Title for a notification without a type.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notificationsFallbackTitle;

  /// Title for a comment_on_post notification.
  ///
  /// In en, this message translates to:
  /// **'New Comment'**
  String get notificationsTypeCommentOnPost;

  /// Title for a reply_to_comment notification.
  ///
  /// In en, this message translates to:
  /// **'New Reply'**
  String get notificationsTypeReplyToComment;

  /// Title for a user_followed notification.
  ///
  /// In en, this message translates to:
  /// **'New Follower'**
  String get notificationsTypeUserFollowed;

  /// Title for an achievement_unlocked notification.
  ///
  /// In en, this message translates to:
  /// **'Achievement Unlocked'**
  String get notificationsTypeAchievementUnlocked;

  /// Title for a post_created notification from someone the user follows.
  ///
  /// In en, this message translates to:
  /// **'New Post'**
  String get notificationsTypePostCreated;

  /// Title of the rewarded video card.
  ///
  /// In en, this message translates to:
  /// **'Watch & Earn'**
  String get adRewardTitle;

  /// Rewarded video card subtitle while videos remain today.
  ///
  /// In en, this message translates to:
  /// **'Watch a short video for +{xp} XP · {remaining}/{limit} left today'**
  String adRewardAvailable(int xp, int remaining, int limit);

  /// Rewarded video card subtitle once the daily limit is used.
  ///
  /// In en, this message translates to:
  /// **'All {limit} videos watched. Come back tomorrow!'**
  String adRewardExhausted(int limit);

  /// Rewarded ads are not set up on this device.
  ///
  /// In en, this message translates to:
  /// **'Rewarded videos are not available.'**
  String get adRewardUnavailable;

  /// The ad network had no video to show.
  ///
  /// In en, this message translates to:
  /// **'No video available right now.'**
  String get adRewardNoVideo;

  /// The video failed to open.
  ///
  /// In en, this message translates to:
  /// **'The video could not be shown.'**
  String get adRewardShowFailed;

  /// The video was closed before the reward.
  ///
  /// In en, this message translates to:
  /// **'Watch the full video to earn XP.'**
  String get adRewardNotCompleted;

  /// XP confirmed by the server.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP added!'**
  String adRewardGranted(int xp);

  /// The server has not confirmed the view yet.
  ///
  /// In en, this message translates to:
  /// **'Thanks! Your +{xp} XP will appear once the view is verified.'**
  String adRewardPending(int xp);

  /// Server rejected the view: daily video limit.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used all rewarded videos for today.'**
  String get adRewardDailyLimit;

  /// Server rejected the view: daily XP cap.
  ///
  /// In en, this message translates to:
  /// **'Daily XP cap reached, no XP this time.'**
  String get adRewardDailyXpCap;

  /// Server rejected the view: ticket expired.
  ///
  /// In en, this message translates to:
  /// **'That took too long. Please try again.'**
  String get adRewardExpired;

  /// Server rejected the view for another reason.
  ///
  /// In en, this message translates to:
  /// **'This view couldn\'t be verified.'**
  String get adRewardUnverified;

  /// Optional update banner title.
  ///
  /// In en, this message translates to:
  /// **'Update available: v{version}'**
  String updateAvailable(String version);

  /// Dismisses the optional update banner.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updateLater;

  /// Starts the optional update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateAction;

  /// Title of the blocking update screen.
  ///
  /// In en, this message translates to:
  /// **'Update required'**
  String get updateRequiredTitle;

  /// Body of the blocking update screen.
  ///
  /// In en, this message translates to:
  /// **'This version of GameDiscoveries is no longer supported. Update to v{version} to keep playing.'**
  String updateRequiredMessage(String version);

  /// Update button while the store opens.
  ///
  /// In en, this message translates to:
  /// **'Opening…'**
  String get updateOpening;

  /// Starts the required update.
  ///
  /// In en, this message translates to:
  /// **'Update now'**
  String get updateNow;

  /// Tagline under the logo on the splash screen.
  ///
  /// In en, this message translates to:
  /// **'Discover. Play. Progress.'**
  String get splashTagline;

  /// Splash screen loading text.
  ///
  /// In en, this message translates to:
  /// **'Loading your next adventure...'**
  String get splashLoading;

  /// Number of games the player has played.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 game played} other{{count} games played}}'**
  String progressGamesPlayed(int count);

  /// Player level label.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String progressLevel(int level);

  /// Total XP earned. XP stays untranslated.
  ///
  /// In en, this message translates to:
  /// **'Total {xp} XP'**
  String progressTotalXp(int xp);

  /// Label for the daily play streak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get progressCurrentStreak;

  /// Greeting with the player's display name.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {username}'**
  String profileWelcome(String username);

  /// Title of the profile screen.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Fallback name when the player has no display name.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get profileDefaultName;

  /// Name shown on the profile of a signed-out player.
  ///
  /// In en, this message translates to:
  /// **'Guest Player'**
  String get profileGuestName;

  /// Prompt on the guest profile.
  ///
  /// In en, this message translates to:
  /// **'Create an account to save XP, streaks, favorites and achievements.'**
  String get profileGuestPrompt;

  /// Profile menu item.
  ///
  /// In en, this message translates to:
  /// **'My Progress'**
  String get profileMyProgress;

  /// Profile menu item and statistic label.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get profileAchievements;

  /// Profile menu item.
  ///
  /// In en, this message translates to:
  /// **'My Favorites'**
  String get profileMyFavorites;

  /// Profile menu item.
  ///
  /// In en, this message translates to:
  /// **'Play History'**
  String get profilePlayHistory;

  /// Profile menu item.
  ///
  /// In en, this message translates to:
  /// **'My Reviews'**
  String get profileMyReviews;

  /// Profile menu item and title of the help screen.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get profileHelpSupport;

  /// Profile menu item.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get profileLeaderboard;

  /// Profile menu item.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get profileCommunity;

  /// Profile menu item.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// Section title above secondary profile links.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get profileMore;

  /// Short statistic label for game counts.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get profileStatGames;

  /// Short statistic label for total XP.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get profileStatPoints;

  /// Screen reader label of the sessions statistic.
  ///
  /// In en, this message translates to:
  /// **'Game sessions played'**
  String get profileStatSessionsSemantics;

  /// Screen reader label of the unique games statistic.
  ///
  /// In en, this message translates to:
  /// **'Different games played'**
  String get profileStatUniqueGamesSemantics;

  /// Screen reader label of the achievements statistic.
  ///
  /// In en, this message translates to:
  /// **'Achievements unlocked'**
  String get profileStatAchievementsSemantics;

  /// Screen reader label of the XP statistic.
  ///
  /// In en, this message translates to:
  /// **'Total XP points'**
  String get profileStatPointsSemantics;

  /// Screen reader label of a statistic that could not be loaded.
  ///
  /// In en, this message translates to:
  /// **'{label}: not available'**
  String profileStatUnavailableSemantics(String label);

  /// Level label while progress is loading.
  ///
  /// In en, this message translates to:
  /// **'Level —'**
  String get profileLevelUnknown;

  /// Badge shown when the player reached the highest level.
  ///
  /// In en, this message translates to:
  /// **'MAX LEVEL'**
  String get profileMaxLevel;

  /// Screen reader label while level progress loads.
  ///
  /// In en, this message translates to:
  /// **'Level progress loading'**
  String get profileLevelLoadingSemantics;

  /// Screen reader label at the highest level.
  ///
  /// In en, this message translates to:
  /// **'Level {level}, maximum level reached'**
  String profileLevelMaxSemantics(int level);

  /// Screen reader label of the XP progress bar.
  ///
  /// In en, this message translates to:
  /// **'Level {level}, {current} of {next} XP'**
  String profileLevelProgressSemantics(int level, int current, int next);

  /// Title of the avatar sheet and avatar button label.
  ///
  /// In en, this message translates to:
  /// **'Change avatar'**
  String get profileChangeAvatar;

  /// Screen reader label while the avatar uploads.
  ///
  /// In en, this message translates to:
  /// **'Uploading avatar'**
  String get profileUploadingAvatar;

  /// Avatar sheet option.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get profileChooseFromGallery;

  /// Avatar sheet option.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get profileTakePhoto;

  /// Avatar sheet option.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get profileRemovePhoto;

  /// Snackbar after a new avatar is saved.
  ///
  /// In en, this message translates to:
  /// **'Avatar updated.'**
  String get profileAvatarUpdated;

  /// Snackbar after the avatar is removed.
  ///
  /// In en, this message translates to:
  /// **'Avatar removed.'**
  String get profileAvatarRemoved;

  /// Snackbar when the camera or gallery cannot open.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the camera or photos. Check the app permissions.'**
  String get profileAvatarPermissionError;

  /// Snackbar when the picked image exceeds the upload limit.
  ///
  /// In en, this message translates to:
  /// **'Image must be {maxMb} MB or smaller.'**
  String profileAvatarTooLarge(int maxMb);

  /// Title of the sign out confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutTitle;

  /// Body of the sign out confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Your progress stays saved on your account.'**
  String get signOutMessage;

  /// FAQ question.
  ///
  /// In en, this message translates to:
  /// **'How do I earn XP?'**
  String get helpFaqEarnXpQuestion;

  /// FAQ answer.
  ///
  /// In en, this message translates to:
  /// **'Play games, complete missions and unlock achievements while signed in. XP is awarded by our servers, so it may take a moment to show up in your profile.'**
  String get helpFaqEarnXpAnswer;

  /// FAQ question.
  ///
  /// In en, this message translates to:
  /// **'Why didn\'t my progress save?'**
  String get helpFaqProgressQuestion;

  /// FAQ answer.
  ///
  /// In en, this message translates to:
  /// **'XP, streaks, favorites and achievements are only saved to your account while you are signed in.'**
  String get helpFaqProgressAnswer;

  /// FAQ question.
  ///
  /// In en, this message translates to:
  /// **'What are missions?'**
  String get helpFaqMissionsQuestion;

  /// FAQ answer.
  ///
  /// In en, this message translates to:
  /// **'Missions are challenges that refresh on a schedule. Open the Missions tab to see what is active and how much XP each one rewards.'**
  String get helpFaqMissionsAnswer;

  /// FAQ question.
  ///
  /// In en, this message translates to:
  /// **'A game won\'t load. What can I do?'**
  String get helpFaqGameLoadQuestion;

  /// FAQ answer.
  ///
  /// In en, this message translates to:
  /// **'Games are provided by third-party publishers and need a stable internet connection. Go back and open the game again, or try another game.'**
  String get helpFaqGameLoadAnswer;

  /// FAQ question.
  ///
  /// In en, this message translates to:
  /// **'How do I sign out?'**
  String get helpFaqSignOutQuestion;

  /// FAQ answer.
  ///
  /// In en, this message translates to:
  /// **'Open Account Settings from your profile and tap Sign Out.'**
  String get helpFaqSignOutAnswer;

  /// Screen reader label of a menu item that is not available yet.
  ///
  /// In en, this message translates to:
  /// **'{label}, coming soon'**
  String profileComingSoonSemantics(String label);

  /// Filter option that shows every item.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get commonAll;

  /// Share button tooltip.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get commonShare;

  /// Notifications button tooltip.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get commonNotifications;

  /// Replaces the current player's own name in lists.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get commonYou;

  /// Button that opens game discovery from an empty state.
  ///
  /// In en, this message translates to:
  /// **'Find a Game'**
  String get commonFindGame;

  /// Short badge for the maximum level.
  ///
  /// In en, this message translates to:
  /// **'MAX'**
  String get commonMaxShort;

  /// Compact player level badge.
  ///
  /// In en, this message translates to:
  /// **'Lv {level}'**
  String commonLevelShort(int level);

  /// XP reward amount.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP'**
  String commonXpReward(int xp);

  /// Signed or plain XP amount, e.g. a score or a deduction.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP'**
  String commonXpAmount(int xp);

  /// XP earned in the current level out of the XP needed.
  ///
  /// In en, this message translates to:
  /// **'{current} / {next} XP'**
  String commonXpProgress(int current, int next);

  /// Home header greeting with the player's first name.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name} 👋'**
  String homeGreeting(String name);

  /// Home header link for guests.
  ///
  /// In en, this message translates to:
  /// **'Sign in to earn XP & level up'**
  String get homeSignInPrompt;

  /// Screen reader label of the home XP bar.
  ///
  /// In en, this message translates to:
  /// **'Level progress'**
  String get homeLevelProgressSemantics;

  /// Screen reader label of the home banner image.
  ///
  /// In en, this message translates to:
  /// **'New Adventures Every Day. Explore the latest and trending games!'**
  String get homeBannerSemantics;

  /// Home empty state.
  ///
  /// In en, this message translates to:
  /// **'No games to show yet. Check back soon.'**
  String get homeEmpty;

  /// Home shelf title.
  ///
  /// In en, this message translates to:
  /// **'Recommended For You'**
  String get homeShelfRecommended;

  /// Home shelf title.
  ///
  /// In en, this message translates to:
  /// **'Trending Now'**
  String get homeShelfTrending;

  /// Home shelf title.
  ///
  /// In en, this message translates to:
  /// **'Made for Mobile'**
  String get homeShelfMobile;

  /// Home shelf title.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get homeShelfPopular;

  /// Home shelf title.
  ///
  /// In en, this message translates to:
  /// **'New Releases'**
  String get homeShelfNewReleases;

  /// Home shelf title.
  ///
  /// In en, this message translates to:
  /// **'Hot Games'**
  String get homeShelfHot;

  /// Home shelf title.
  ///
  /// In en, this message translates to:
  /// **'Most Played'**
  String get homeShelfMostPlayed;

  /// Home shelf title.
  ///
  /// In en, this message translates to:
  /// **'Best Games'**
  String get homeShelfBest;

  /// Home shelf title.
  ///
  /// In en, this message translates to:
  /// **'Multiplayer'**
  String get homeShelfMultiplayer;

  /// Home shelf title.
  ///
  /// In en, this message translates to:
  /// **'Exclusive'**
  String get homeShelfExclusive;

  /// Badge on the featured carousel.
  ///
  /// In en, this message translates to:
  /// **'FEATURED'**
  String get homeFeaturedBadge;

  /// Screen reader label of a featured game.
  ///
  /// In en, this message translates to:
  /// **'Featured: {title}'**
  String homeFeaturedSemantics(String title);

  /// Section title on the play tab.
  ///
  /// In en, this message translates to:
  /// **'Quick Play'**
  String get playQuickPlay;

  /// Empty state of quick play.
  ///
  /// In en, this message translates to:
  /// **'No quick play picks right now.'**
  String get playEmpty;

  /// Tooltip of the round play button.
  ///
  /// In en, this message translates to:
  /// **'Play now'**
  String get playNowTooltip;

  /// Discover sort option.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get discoverSortTrending;

  /// Discover sort option.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get discoverSortNew;

  /// Discover sort option.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get discoverSortPopular;

  /// Discover sort option by title.
  ///
  /// In en, this message translates to:
  /// **'A–Z'**
  String get discoverSortAz;

  /// Discover empty search title.
  ///
  /// In en, this message translates to:
  /// **'No games found'**
  String get discoverNoResultsTitle;

  /// Discover empty search message.
  ///
  /// In en, this message translates to:
  /// **'Try another keyword or category.'**
  String get discoverNoResultsMessage;

  /// Game detail tab.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get gameTabAbout;

  /// Game detail tab.
  ///
  /// In en, this message translates to:
  /// **'How to Play'**
  String get gameTabHowToPlay;

  /// Game detail tab.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get gameTabReviews;

  /// Game detail tab.
  ///
  /// In en, this message translates to:
  /// **'Similar'**
  String get gameTabSimilar;

  /// Chip for games played in landscape.
  ///
  /// In en, this message translates to:
  /// **'Landscape'**
  String get gameLandscape;

  /// Chip for games played in portrait.
  ///
  /// In en, this message translates to:
  /// **'Portrait'**
  String get gamePortrait;

  /// Primary play button on game detail.
  ///
  /// In en, this message translates to:
  /// **'Play Now'**
  String get gamePlayNow;

  /// Disabled play button when the game cannot be played.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get gameNotAvailable;

  /// Screen reader label of the hero play button.
  ///
  /// In en, this message translates to:
  /// **'Play {title}'**
  String gamePlaySemantics(String title);

  /// Placeholder when a game has no description.
  ///
  /// In en, this message translates to:
  /// **'No description yet.'**
  String get gameNoDescription;

  /// Placeholder when a game has no instructions.
  ///
  /// In en, this message translates to:
  /// **'Just tap Play Now and follow the in-game tutorial.'**
  String get gameDefaultInstructions;

  /// Empty reviews tab.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet. Be the first after you play!'**
  String get gameNoReviews;

  /// Shelf title of similar games.
  ///
  /// In en, this message translates to:
  /// **'Similar Games'**
  String get gameSimilarGames;

  /// Empty similar games tab.
  ///
  /// In en, this message translates to:
  /// **'No similar games found.'**
  String get gameNoSimilar;

  /// Rating row when there are no reviews.
  ///
  /// In en, this message translates to:
  /// **'No ratings yet'**
  String get gameNoRatings;

  /// Number of reviews next to the average rating.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{(1 review)} other{({count} reviews)}}'**
  String gameReviewCount(int count);

  /// Developer credit. The developer name is not translated.
  ///
  /// In en, this message translates to:
  /// **'by {developer}'**
  String gameByDeveloper(String developer);

  /// Text shared with a game link.
  ///
  /// In en, this message translates to:
  /// **'Play {title} on GameDiscoveries: {url}'**
  String gameShareText(String title, String url);

  /// Player error when the game page fails.
  ///
  /// In en, this message translates to:
  /// **'The game could not be loaded.'**
  String get playerLoadFailed;

  /// Player error when the game has no mobile URL.
  ///
  /// In en, this message translates to:
  /// **'This game is not available on mobile yet.'**
  String get playerUnsupported;

  /// Player error title.
  ///
  /// In en, this message translates to:
  /// **'Game unavailable'**
  String get playerUnavailableTitle;

  /// Tooltip of the pause button.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get playerPause;

  /// Pause overlay title.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get playerPaused;

  /// Pause overlay button.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get playerResume;

  /// Pause overlay button.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get playerRestart;

  /// Pause overlay button.
  ///
  /// In en, this message translates to:
  /// **'Exit Game'**
  String get playerExit;

  /// Community screen title.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get communityTitle;

  /// Prompt when a guest tries to post.
  ///
  /// In en, this message translates to:
  /// **'Sign in to post in the community.'**
  String get communitySignInToPost;

  /// Prompt when a guest tries to like.
  ///
  /// In en, this message translates to:
  /// **'Sign in to like posts.'**
  String get communitySignInToLike;

  /// Prompt when a guest tries to report.
  ///
  /// In en, this message translates to:
  /// **'Sign in to report posts.'**
  String get communitySignInToReport;

  /// Comment bar text for guests.
  ///
  /// In en, this message translates to:
  /// **'Sign in to join the conversation.'**
  String get communitySignInToComment;

  /// Used in share text when a post has no title.
  ///
  /// In en, this message translates to:
  /// **'a community post'**
  String get communityShareFallbackTitle;

  /// Text shared with a community post link.
  ///
  /// In en, this message translates to:
  /// **'Check out \"{title}\" on GameDiscoveries: {url}'**
  String communityShareText(String title, String url);

  /// Snackbar after bookmarking a post.
  ///
  /// In en, this message translates to:
  /// **'Saved to your posts.'**
  String get communitySavedToPosts;

  /// Snackbar after removing a bookmark.
  ///
  /// In en, this message translates to:
  /// **'Removed from saved.'**
  String get communityRemovedFromSaved;

  /// Post action.
  ///
  /// In en, this message translates to:
  /// **'Share post'**
  String get communitySharePost;

  /// Post action.
  ///
  /// In en, this message translates to:
  /// **'Save post'**
  String get communitySavePost;

  /// Post action.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved'**
  String get communityRemoveFromSaved;

  /// Post action.
  ///
  /// In en, this message translates to:
  /// **'Report post'**
  String get communityReportPost;

  /// Post action.
  ///
  /// In en, this message translates to:
  /// **'Delete post'**
  String get communityDeletePost;

  /// Tooltip of the post menu button.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get communityMoreOptions;

  /// Report reason dialog title.
  ///
  /// In en, this message translates to:
  /// **'Why are you reporting this?'**
  String get communityReportTitle;

  /// Report reason.
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get communityReportSpam;

  /// Report reason.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get communityReportHarassment;

  /// Report reason.
  ///
  /// In en, this message translates to:
  /// **'Misleading'**
  String get communityReportMisleading;

  /// Report reason.
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get communityReportOther;

  /// Snackbar after reporting.
  ///
  /// In en, this message translates to:
  /// **'Thanks, we\'ll review this post.'**
  String get communityReportThanks;

  /// Delete post dialog title.
  ///
  /// In en, this message translates to:
  /// **'Delete post?'**
  String get communityDeletePostTitle;

  /// Delete post dialog body.
  ///
  /// In en, this message translates to:
  /// **'Your post and its comments will be removed.'**
  String get communityDeletePostMessage;

  /// Snackbar after deleting a post.
  ///
  /// In en, this message translates to:
  /// **'Post deleted.'**
  String get communityPostDeleted;

  /// Community section a post belongs to.
  ///
  /// In en, this message translates to:
  /// **'in {section}'**
  String communityInSection(String section);

  /// Community section name.
  ///
  /// In en, this message translates to:
  /// **'Discussions'**
  String get communitySectionDiscussions;

  /// Community section name.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get communitySectionQuestions;

  /// Community section name.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get communitySectionRecommendations;

  /// Community section name.
  ///
  /// In en, this message translates to:
  /// **'Game Shares'**
  String get communitySectionGameShares;

  /// Community section name.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get communitySectionAchievements;

  /// Screen reader label of a linked game.
  ///
  /// In en, this message translates to:
  /// **'Open {title}'**
  String communityOpenGame(String title);

  /// Screen reader label of a post's like count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 like} other{{count} likes}}'**
  String communityLikesSemantics(int count);

  /// Screen reader label of the like button.
  ///
  /// In en, this message translates to:
  /// **'Like post'**
  String get communityLikePost;

  /// Screen reader label of the like button when liked.
  ///
  /// In en, this message translates to:
  /// **'Unlike post'**
  String get communityUnlikePost;

  /// Like button text.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get communityLike;

  /// Like button text when liked.
  ///
  /// In en, this message translates to:
  /// **'Liked'**
  String get communityLiked;

  /// Search field hint and tooltip.
  ///
  /// In en, this message translates to:
  /// **'Search posts'**
  String get communitySearchPosts;

  /// Tooltip that closes search.
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get communityCloseSearch;

  /// Tooltip that opens saved posts.
  ///
  /// In en, this message translates to:
  /// **'Saved posts'**
  String get communitySavedPostsTooltip;

  /// Saved posts screen title.
  ///
  /// In en, this message translates to:
  /// **'Saved Posts'**
  String get communitySavedPostsTitle;

  /// Tooltip of the compose button.
  ///
  /// In en, this message translates to:
  /// **'New post'**
  String get communityNewPostTooltip;

  /// Composer sheet title.
  ///
  /// In en, this message translates to:
  /// **'New Post'**
  String get communityNewPostTitle;

  /// Community sort tab.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get communitySortLatest;

  /// Community sort tab.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get communitySortTrending;

  /// Community sort tab.
  ///
  /// In en, this message translates to:
  /// **'Most Liked'**
  String get communitySortMostLiked;

  /// Empty feed title.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get communityEmptyTitle;

  /// Empty feed message.
  ///
  /// In en, this message translates to:
  /// **'Start the conversation with the + button.'**
  String get communityEmptyMessage;

  /// Empty search title.
  ///
  /// In en, this message translates to:
  /// **'No posts found'**
  String get communityNoResultsTitle;

  /// Empty search message.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches \"{query}\". Try another word.'**
  String communityNoResultsMessage(String query);

  /// Empty saved posts title.
  ///
  /// In en, this message translates to:
  /// **'No saved posts'**
  String get communityNoSavedTitle;

  /// Empty saved posts message.
  ///
  /// In en, this message translates to:
  /// **'Tap the bookmark on a post to keep it here.'**
  String get communityNoSavedMessage;

  /// Composer validation error.
  ///
  /// In en, this message translates to:
  /// **'Title and message are required.'**
  String get communityComposerRequired;

  /// Post type option.
  ///
  /// In en, this message translates to:
  /// **'Discussion'**
  String get communityTypeDiscussion;

  /// Post type option.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get communityTypeQuestion;

  /// Composer title placeholder.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get communityTitleHint;

  /// Composer body placeholder.
  ///
  /// In en, this message translates to:
  /// **'Share something with the community...'**
  String get communityContentHint;

  /// Button that publishes a post.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get communityPublish;

  /// Post detail screen title.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get communityPostTitle;

  /// Delete comment dialog title.
  ///
  /// In en, this message translates to:
  /// **'Delete comment?'**
  String get communityDeleteCommentTitle;

  /// Delete comment dialog body.
  ///
  /// In en, this message translates to:
  /// **'Your comment will be removed.'**
  String get communityDeleteCommentMessage;

  /// Snackbar after deleting a comment.
  ///
  /// In en, this message translates to:
  /// **'Comment deleted.'**
  String get communityCommentDeleted;

  /// Comments section title with the total count.
  ///
  /// In en, this message translates to:
  /// **'Comments ({count})'**
  String communityComments(int count);

  /// Empty comments state.
  ///
  /// In en, this message translates to:
  /// **'No comments yet. Start the conversation!'**
  String get communityNoComments;

  /// Reply button on a comment.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get communityReply;

  /// Composer banner while replying.
  ///
  /// In en, this message translates to:
  /// **'Replying to {name}'**
  String communityReplyingTo(String name);

  /// Tooltip that cancels a reply.
  ///
  /// In en, this message translates to:
  /// **'Cancel reply'**
  String get communityCancelReply;

  /// Comment field placeholder.
  ///
  /// In en, this message translates to:
  /// **'Write a comment...'**
  String get communityWriteComment;

  /// Reply field placeholder.
  ///
  /// In en, this message translates to:
  /// **'Write a reply...'**
  String get communityWriteReply;

  /// Tooltip of the send button.
  ///
  /// In en, this message translates to:
  /// **'Send comment'**
  String get communitySendComment;

  /// Favorites screen title for guests.
  ///
  /// In en, this message translates to:
  /// **'Save your favorites'**
  String get favoritesSignInTitle;

  /// Favorites screen message for guests.
  ///
  /// In en, this message translates to:
  /// **'Sign in to keep a list of games you love.'**
  String get favoritesSignInMessage;

  /// Empty favorites title.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get favoritesEmptyTitle;

  /// Empty favorites message.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on any game to save it here.'**
  String get favoritesEmptyMessage;

  /// Empty favorites button.
  ///
  /// In en, this message translates to:
  /// **'Discover Games'**
  String get favoritesDiscoverGames;

  /// Tooltip of the heart button.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get favoritesAdd;

  /// Tooltip of the filled heart button.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get favoritesRemove;

  /// Snackbar when a guest taps the heart.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save your favorite games.'**
  String get favoritesSignInPrompt;

  /// History screen title for guests.
  ///
  /// In en, this message translates to:
  /// **'Your play history'**
  String get historySignInTitle;

  /// History screen message for guests.
  ///
  /// In en, this message translates to:
  /// **'Sign in to pick up right where you left off.'**
  String get historySignInMessage;

  /// Empty history title.
  ///
  /// In en, this message translates to:
  /// **'Nothing played yet'**
  String get historyEmptyTitle;

  /// Empty history message.
  ///
  /// In en, this message translates to:
  /// **'Games you play will show up here.'**
  String get historyEmptyMessage;

  /// How many times a game was played.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 play} other{{count} plays}}'**
  String historyPlayCount(int count);

  /// Section title of the last played game.
  ///
  /// In en, this message translates to:
  /// **'Continue Playing'**
  String get historyContinuePlaying;

  /// Shelf title of recently played games.
  ///
  /// In en, this message translates to:
  /// **'Recently Played'**
  String get historyRecentlyPlayed;

  /// Button that resumes the last played game.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get historyContinue;

  /// Platform the game was last played on. Platform names are not translated.
  ///
  /// In en, this message translates to:
  /// **'on {platform}'**
  String historyPlayedOn(String platform);

  /// Total play time of a game.
  ///
  /// In en, this message translates to:
  /// **'{time} total'**
  String historyTotalTime(String time);

  /// My reviews title for guests.
  ///
  /// In en, this message translates to:
  /// **'Your reviews'**
  String get reviewsSignInTitle;

  /// My reviews message for guests.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see and manage the reviews you wrote.'**
  String get reviewsSignInMessage;

  /// Empty reviews title.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get reviewsEmptyTitle;

  /// Empty reviews message.
  ///
  /// In en, this message translates to:
  /// **'Play a game, then share what you think on its page.'**
  String get reviewsEmptyMessage;

  /// Delete review dialog title.
  ///
  /// In en, this message translates to:
  /// **'Delete review?'**
  String get reviewsDeleteTitle;

  /// Delete review dialog body. The game title is not translated.
  ///
  /// In en, this message translates to:
  /// **'Your review of {game} will be removed.'**
  String reviewsDeleteMessage(String game);

  /// Snackbar after deleting a review.
  ///
  /// In en, this message translates to:
  /// **'Review deleted'**
  String get reviewsDeleted;

  /// Tooltip of the delete review button.
  ///
  /// In en, this message translates to:
  /// **'Delete review'**
  String get reviewsDeleteTooltip;

  /// Screen reader label of the star rating.
  ///
  /// In en, this message translates to:
  /// **'Rated {rating} out of 5'**
  String reviewsRatedSemantics(int rating);

  /// Badge on a review hidden by moderation.
  ///
  /// In en, this message translates to:
  /// **'Hidden by moderators'**
  String get reviewsHidden;

  /// Missions title for guests.
  ///
  /// In en, this message translates to:
  /// **'Daily & weekly missions'**
  String get missionsSignInTitle;

  /// Missions message for guests.
  ///
  /// In en, this message translates to:
  /// **'Sign in to get missions, earn bonus XP and keep your streak alive.'**
  String get missionsSignInMessage;

  /// Missions tab.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get missionsDaily;

  /// Missions tab.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get missionsWeekly;

  /// Empty missions state.
  ///
  /// In en, this message translates to:
  /// **'No missions right now. New ones arrive soon.'**
  String get missionsEmpty;

  /// Missions banner title.
  ///
  /// In en, this message translates to:
  /// **'Complete Daily Missions'**
  String get missionsCompleteDaily;

  /// Missions banner title.
  ///
  /// In en, this message translates to:
  /// **'Complete Weekly Missions'**
  String get missionsCompleteWeekly;

  /// Total XP available from the listed missions.
  ///
  /// In en, this message translates to:
  /// **'Earn up to {xp} XP'**
  String missionsEarnUpTo(int xp);

  /// Screen reader label of the missions progress bar.
  ///
  /// In en, this message translates to:
  /// **'Missions completed'**
  String get missionsCompletedSemantics;

  /// Achievements title for guests.
  ///
  /// In en, this message translates to:
  /// **'Unlock achievements'**
  String get achievementsSignInTitle;

  /// Achievements message for guests.
  ///
  /// In en, this message translates to:
  /// **'Sign in to collect badges as you play and explore.'**
  String get achievementsSignInMessage;

  /// Follows the highlighted unlocked count, e.g. '3 / 20 Unlocked'.
  ///
  /// In en, this message translates to:
  /// **' / {total} Unlocked'**
  String achievementsUnlockedOf(int total);

  /// Screen reader label of the achievements progress bar.
  ///
  /// In en, this message translates to:
  /// **'Achievements unlocked'**
  String get achievementsUnlockedSemantics;

  /// Empty achievements category.
  ///
  /// In en, this message translates to:
  /// **'No achievements in this category yet.'**
  String get achievementsEmptyCategory;

  /// Screen reader label of a hidden achievement.
  ///
  /// In en, this message translates to:
  /// **'Secret achievement'**
  String get achievementsSecretSemantics;

  /// Title of a hidden achievement.
  ///
  /// In en, this message translates to:
  /// **'Secret Achievement'**
  String get achievementsSecretTitle;

  /// Description of a hidden achievement.
  ///
  /// In en, this message translates to:
  /// **'Keep playing to discover this one.'**
  String get achievementsSecretHint;

  /// When the achievement was unlocked, e.g. 'Unlocked 2h ago'.
  ///
  /// In en, this message translates to:
  /// **'Unlocked {time}'**
  String achievementsUnlockedAt(String time);

  /// Status of a locked hidden achievement.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get achievementsLocked;

  /// Achievement progress.
  ///
  /// In en, this message translates to:
  /// **'Progress {current}/{target}'**
  String achievementsProgress(int current, int target);

  /// Progress title for guests.
  ///
  /// In en, this message translates to:
  /// **'Track your progress'**
  String get progressSignInTitle;

  /// Progress message for guests.
  ///
  /// In en, this message translates to:
  /// **'Sign in to earn XP, level up and build your streak.'**
  String get progressSignInMessage;

  /// Abbreviation above the level number in the badge.
  ///
  /// In en, this message translates to:
  /// **'Lv'**
  String get progressLevelBadge;

  /// Shown instead of XP progress at the highest level.
  ///
  /// In en, this message translates to:
  /// **'Max level reached'**
  String get progressMaxLevelReached;

  /// Compact streak length in days.
  ///
  /// In en, this message translates to:
  /// **'{days}d'**
  String progressStreakDays(int days);

  /// Statistic label.
  ///
  /// In en, this message translates to:
  /// **'Games Played'**
  String get progressGamesPlayedLabel;

  /// Section title of recent XP transactions.
  ///
  /// In en, this message translates to:
  /// **'Recent XP Activity'**
  String get progressRecentXp;

  /// Empty XP activity.
  ///
  /// In en, this message translates to:
  /// **'Play a game to start earning XP.'**
  String get progressNoXp;

  /// Fallback label of an XP transaction.
  ///
  /// In en, this message translates to:
  /// **'XP earned'**
  String get progressXpEarned;

  /// Empty leaderboard title.
  ///
  /// In en, this message translates to:
  /// **'No rankings yet'**
  String get leaderboardEmptyTitle;

  /// Empty leaderboard message.
  ///
  /// In en, this message translates to:
  /// **'Play games to be the first on the board!'**
  String get leaderboardEmptyMessage;

  /// Leaderboard tab for all-time rankings.
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get leaderboardScopeGlobal;

  /// Leaderboard tab.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get leaderboardScopeWeekly;

  /// Leaderboard tab.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get leaderboardScopeMonthly;

  /// Time left in the current leaderboard period.
  ///
  /// In en, this message translates to:
  /// **'Season ends in {time}'**
  String leaderboardSeasonEndsIn(String time);

  /// Screen reader label of a podium spot.
  ///
  /// In en, this message translates to:
  /// **'Rank {rank}, {name}, {score} XP'**
  String leaderboardPodiumSemantics(int rank, String name, int score);

  /// Screen reader label of a leaderboard row.
  ///
  /// In en, this message translates to:
  /// **'Rank {rank}, {name}, {detail}, {score} XP'**
  String leaderboardRowSemantics(
    int rank,
    String name,
    String detail,
    int score,
  );

  /// Rank bar for signed-in players without a rank.
  ///
  /// In en, this message translates to:
  /// **'Play a game to get ranked.'**
  String get leaderboardPlayToRank;

  /// Rank bar for guests.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see your rank.'**
  String get leaderboardSignInToRank;
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
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
