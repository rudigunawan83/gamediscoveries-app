// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navigationHome => 'Home';

  @override
  String get navigationDiscover => 'Discover';

  @override
  String get navigationPlay => 'Play';

  @override
  String get navigationMissions => 'Missions';

  @override
  String get navigationProfile => 'Profile';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonSignIn => 'Sign In';

  @override
  String get commonCreateAccount => 'Create an account';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonBack => 'Back';

  @override
  String get commonNext => 'Next';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonSeeAll => 'See All';

  @override
  String get commonSearchGames => 'Search games...';

  @override
  String get commonClearSearch => 'Clear search';

  @override
  String get commonMobileBadge => 'Mobile';

  @override
  String get commonSoon => 'Soon';

  @override
  String get commonSignOut => 'Sign Out';

  @override
  String get settingsTitle => 'Account Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSubtitle => 'Choose your preferred language';

  @override
  String get settingsSystemDefault => 'System default';

  @override
  String get settingsEnglish => 'English';

  @override
  String get settingsIndonesian => 'Bahasa Indonesia';

  @override
  String get settingsLanguageChanged => 'Language updated';

  @override
  String get settingsManageAccountTitle => 'Manage your account';

  @override
  String get settingsManageAccountMessage =>
      'Sign in to view and manage your account.';

  @override
  String get settingsDisplayName => 'Display name';

  @override
  String get settingsUsername => 'Username';

  @override
  String get settingsEmail => 'Email';

  @override
  String get settingsDisplayNameHint =>
      'The name other people see. 2–40 characters.';

  @override
  String get settingsDisplayNameInvalid => 'Use 2–40 characters.';

  @override
  String get settingsUsernameHint =>
      'Letters, numbers, or hyphens. 3–30 characters.';

  @override
  String get settingsUsernameInvalid =>
      'Use 3–30 letters, numbers, or hyphens.';

  @override
  String get settingsUsernameTaken => 'That username is already taken.';

  @override
  String get settingsSave => 'Save profile';

  @override
  String get settingsSaving => 'Saving…';

  @override
  String get settingsProfileSaved => 'Profile updated';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsPrivacyShowFavorites => 'Show favorites';

  @override
  String get settingsPrivacyShowFavoritesHint =>
      'Others can see games you saved.';

  @override
  String get settingsPrivacyShowHistory => 'Show play history';

  @override
  String get settingsPrivacyShowHistoryHint =>
      'Others can see what you played recently.';

  @override
  String get settingsPrivacyShowAchievements => 'Show achievements';

  @override
  String get settingsPrivacyShowAchievementsHint =>
      'Others can see badges you unlocked.';

  @override
  String get settingsPrivacyShowActivity => 'Show activity';

  @override
  String get settingsPrivacyShowActivityHint =>
      'Your activity appears in the community feed.';

  @override
  String get settingsPrivacyShowOnLeaderboards => 'Show on leaderboards';

  @override
  String get settingsPrivacyShowOnLeaderboardsHint =>
      'Your rank is visible on public leaderboards.';

  @override
  String get authLoginTitle => 'Welcome back';

  @override
  String get authLoginSubtitle =>
      'Sign in to keep your XP, streak and achievements.';

  @override
  String get authRegisterTitle => 'Create your account';

  @override
  String get authRegisterSubtitle =>
      'Earn XP, unlock achievements and compete with players.';

  @override
  String get authCreateAccount => 'Create Account';

  @override
  String get authEmailHint => 'Email';

  @override
  String get authPasswordHint => 'Password';

  @override
  String get authDisplayNameHint => 'Display name';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authEmailRequired => 'Email is required.';

  @override
  String get authEmailInvalid => 'Enter a valid email.';

  @override
  String get authPasswordRequired => 'Password is required.';

  @override
  String authMinCharacters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Use at least $count characters.',
      one: 'Use at least 1 character.',
    );
    return '$_temp0';
  }

  @override
  String get authInvalidCredentials => 'Incorrect email or password.';

  @override
  String get authEmailTaken => 'An account with this email already exists.';

  @override
  String get authNoAccount => 'Don\'t have an account? Create one';

  @override
  String get authHaveAccount => 'Already have an account? Sign in';

  @override
  String get onboardingSlide1Word1 => 'Discover';

  @override
  String get onboardingSlide1Word2 => 'Play';

  @override
  String get onboardingSlide1Word3 => 'Progress';

  @override
  String get onboardingSlide1Body =>
      'Thousands of instant games picked for you. No downloads, just tap and play.';

  @override
  String get onboardingSlide2Word1 => 'Earn';

  @override
  String get onboardingSlide2Word2 => 'Level';

  @override
  String get onboardingSlide2Word3 => 'Compete';

  @override
  String get onboardingSlide2Body =>
      'Earn XP every time you play, complete daily missions, build your streak and climb the leaderboard.';

  @override
  String get onboardingSlide3Word1 => 'Play';

  @override
  String get onboardingSlide3Word2 => 'Share';

  @override
  String get onboardingSlide3Word3 => 'Connect';

  @override
  String get onboardingSlide3Body =>
      'Join a community of gamers, discover new games, earn rewards, and make new friends!';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get onboardingHaveAccount => 'I already have an account';

  @override
  String onboardingPageIndicator(int page, int count) {
    return 'Page $page of $count';
  }

  @override
  String get timeJustNow => 'just now';

  @override
  String timeMinutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String timeHoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String timeDaysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String timeDays(int count) {
    return '${count}d';
  }

  @override
  String timeHours(int count) {
    return '${count}h';
  }

  @override
  String timeMinutes(int count) {
    return '${count}m';
  }

  @override
  String get timeUnderMinute => '<1m';

  @override
  String timeLeft(String time) {
    return '$time left';
  }

  @override
  String get timeExpired => 'Expired';

  @override
  String get errorOffline =>
      'You\'re offline or the connection is unstable. Please try again.';

  @override
  String get errorSessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get errorForbidden => 'You don\'t have access to this content.';

  @override
  String get errorNotFound => 'Content not found.';

  @override
  String get errorTooManyRequests =>
      'Too many requests. Please try again shortly.';

  @override
  String get errorServer =>
      'Our servers are having trouble. Please try again later.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get notificationsMarkAllRead => 'Mark all read';

  @override
  String get notificationsSignInTitle => 'Stay in the loop';

  @override
  String get notificationsSignInMessage =>
      'Sign in to get updates on achievements, missions and replies.';

  @override
  String get notificationsEmpty => 'You\'re all caught up.';

  @override
  String get notificationsFallbackTitle => 'Notification';

  @override
  String get notificationsTypeCommentOnPost => 'New Comment';

  @override
  String get notificationsTypeReplyToComment => 'New Reply';

  @override
  String get notificationsTypeUserFollowed => 'New Follower';

  @override
  String get notificationsTypeAchievementUnlocked => 'Achievement Unlocked';

  @override
  String get notificationsTypePostCreated => 'New Post';

  @override
  String get adRewardTitle => 'Watch & Earn';

  @override
  String adRewardAvailable(int xp, int remaining, int limit) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'Watch a short video for +$xpString XP · $remaining/$limit left today';
  }

  @override
  String adRewardExhausted(int limit) {
    return 'All $limit videos watched. Come back tomorrow!';
  }

  @override
  String get adRewardUnavailable => 'Rewarded videos are not available.';

  @override
  String get adRewardNoVideo => 'No video available right now.';

  @override
  String get adRewardShowFailed => 'The video could not be shown.';

  @override
  String get adRewardNotCompleted => 'Watch the full video to earn XP.';

  @override
  String adRewardGranted(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return '+$xpString XP added!';
  }

  @override
  String adRewardPending(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'Thanks! Your +$xpString XP will appear once the view is verified.';
  }

  @override
  String get adRewardDailyLimit =>
      'You\'ve used all rewarded videos for today.';

  @override
  String get adRewardDailyXpCap => 'Daily XP cap reached, no XP this time.';

  @override
  String get adRewardExpired => 'That took too long. Please try again.';

  @override
  String get adRewardUnverified => 'This view couldn\'t be verified.';

  @override
  String updateAvailable(String version) {
    return 'Update available: v$version';
  }

  @override
  String get updateLater => 'Later';

  @override
  String get updateAction => 'Update';

  @override
  String get updateRequiredTitle => 'Update required';

  @override
  String updateRequiredMessage(String version) {
    return 'This version of GameDiscoveries is no longer supported. Update to v$version to keep playing.';
  }

  @override
  String get updateOpening => 'Opening…';

  @override
  String get updateNow => 'Update now';

  @override
  String get splashTagline => 'Discover. Play. Progress.';

  @override
  String get splashLoading => 'Loading your next adventure...';

  @override
  String progressGamesPlayed(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString games played',
      one: '1 game played',
    );
    return '$_temp0';
  }

  @override
  String progressLevel(int level) {
    return 'Level $level';
  }

  @override
  String progressTotalXp(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'Total $xpString XP';
  }

  @override
  String get progressCurrentStreak => 'Current Streak';

  @override
  String profileWelcome(String username) {
    return 'Welcome, $username';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileDefaultName => 'Player';

  @override
  String get profileGuestName => 'Guest Player';

  @override
  String get profileGuestPrompt =>
      'Create an account to save XP, streaks, favorites and achievements.';

  @override
  String get profileMyProgress => 'My Progress';

  @override
  String get profileAchievements => 'Achievements';

  @override
  String get profileMyFavorites => 'My Favorites';

  @override
  String get profilePlayHistory => 'Play History';

  @override
  String get profileMyReviews => 'My Reviews';

  @override
  String get profileHelpSupport => 'Help & Support';

  @override
  String get profileLeaderboard => 'Leaderboard';

  @override
  String get profileCommunity => 'Community';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileMore => 'More';

  @override
  String get profileStatGames => 'Games';

  @override
  String get profileStatPoints => 'Points';

  @override
  String get profileStatSessionsSemantics => 'Game sessions played';

  @override
  String get profileStatUniqueGamesSemantics => 'Different games played';

  @override
  String get profileStatAchievementsSemantics => 'Achievements unlocked';

  @override
  String get profileStatPointsSemantics => 'Total XP points';

  @override
  String profileStatUnavailableSemantics(String label) {
    return '$label: not available';
  }

  @override
  String get profileLevelUnknown => 'Level —';

  @override
  String get profileMaxLevel => 'MAX LEVEL';

  @override
  String get profileLevelLoadingSemantics => 'Level progress loading';

  @override
  String profileLevelMaxSemantics(int level) {
    return 'Level $level, maximum level reached';
  }

  @override
  String profileLevelProgressSemantics(int level, int current, int next) {
    final intl.NumberFormat currentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String currentString = currentNumberFormat.format(current);
    final intl.NumberFormat nextNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nextString = nextNumberFormat.format(next);

    return 'Level $level, $currentString of $nextString XP';
  }

  @override
  String get profileChangeAvatar => 'Change avatar';

  @override
  String get profileUploadingAvatar => 'Uploading avatar';

  @override
  String get profileChooseFromGallery => 'Choose from gallery';

  @override
  String get profileTakePhoto => 'Take a photo';

  @override
  String get profileRemovePhoto => 'Remove photo';

  @override
  String get profileAvatarUpdated => 'Avatar updated.';

  @override
  String get profileAvatarRemoved => 'Avatar removed.';

  @override
  String get profileAvatarPermissionError =>
      'Couldn\'t open the camera or photos. Check the app permissions.';

  @override
  String profileAvatarTooLarge(int maxMb) {
    return 'Image must be $maxMb MB or smaller.';
  }

  @override
  String get signOutTitle => 'Sign out?';

  @override
  String get signOutMessage => 'Your progress stays saved on your account.';

  @override
  String get helpFaqEarnXpQuestion => 'How do I earn XP?';

  @override
  String get helpFaqEarnXpAnswer =>
      'Play games, complete missions and unlock achievements while signed in. XP is awarded by our servers, so it may take a moment to show up in your profile.';

  @override
  String get helpFaqProgressQuestion => 'Why didn\'t my progress save?';

  @override
  String get helpFaqProgressAnswer =>
      'XP, streaks, favorites and achievements are only saved to your account while you are signed in.';

  @override
  String get helpFaqMissionsQuestion => 'What are missions?';

  @override
  String get helpFaqMissionsAnswer =>
      'Missions are challenges that refresh on a schedule. Open the Missions tab to see what is active and how much XP each one rewards.';

  @override
  String get helpFaqGameLoadQuestion => 'A game won\'t load. What can I do?';

  @override
  String get helpFaqGameLoadAnswer =>
      'Games are provided by third-party publishers and need a stable internet connection. Go back and open the game again, or try another game.';

  @override
  String get helpFaqSignOutQuestion => 'How do I sign out?';

  @override
  String get helpFaqSignOutAnswer =>
      'Open Account Settings from your profile and tap Sign Out.';

  @override
  String profileComingSoonSemantics(String label) {
    return '$label, coming soon';
  }

  @override
  String get commonAll => 'All';

  @override
  String get commonShare => 'Share';

  @override
  String get commonNotifications => 'Notifications';

  @override
  String get commonYou => 'You';

  @override
  String get commonFindGame => 'Find a Game';

  @override
  String get commonMaxShort => 'MAX';

  @override
  String commonLevelShort(int level) {
    return 'Lv $level';
  }

  @override
  String commonXpReward(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return '+$xpString XP';
  }

  @override
  String commonXpAmount(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return '$xpString XP';
  }

  @override
  String commonXpProgress(int current, int next) {
    final intl.NumberFormat currentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String currentString = currentNumberFormat.format(current);
    final intl.NumberFormat nextNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nextString = nextNumberFormat.format(next);

    return '$currentString / $nextString XP';
  }

  @override
  String homeGreeting(String name) {
    return 'Hi, $name 👋';
  }

  @override
  String get homeSignInPrompt => 'Sign in to earn XP & level up';

  @override
  String get homeLevelProgressSemantics => 'Level progress';

  @override
  String get homeBannerSemantics =>
      'New Adventures Every Day. Explore the latest and trending games!';

  @override
  String get homeEmpty => 'No games to show yet. Check back soon.';

  @override
  String get homeShelfRecommended => 'Recommended For You';

  @override
  String get homeShelfTrending => 'Trending Now';

  @override
  String get homeShelfMobile => 'Made for Mobile';

  @override
  String get homeShelfPopular => 'Popular';

  @override
  String get homeShelfNewReleases => 'New Releases';

  @override
  String get homeShelfHot => 'Hot Games';

  @override
  String get homeShelfMostPlayed => 'Most Played';

  @override
  String get homeShelfBest => 'Best Games';

  @override
  String get homeShelfMultiplayer => 'Multiplayer';

  @override
  String get homeShelfExclusive => 'Exclusive';

  @override
  String get homeFeaturedBadge => 'FEATURED';

  @override
  String homeFeaturedSemantics(String title) {
    return 'Featured: $title';
  }

  @override
  String get playQuickPlay => 'Quick Play';

  @override
  String get playEmpty => 'No quick play picks right now.';

  @override
  String get playNowTooltip => 'Play now';

  @override
  String get discoverSortTrending => 'Trending';

  @override
  String get discoverSortNew => 'New';

  @override
  String get discoverSortPopular => 'Popular';

  @override
  String get discoverSortAz => 'A–Z';

  @override
  String get discoverNoResultsTitle => 'No games found';

  @override
  String get discoverNoResultsMessage => 'Try another keyword or category.';

  @override
  String get gameTabAbout => 'About';

  @override
  String get gameTabHowToPlay => 'How to Play';

  @override
  String get gameTabReviews => 'Reviews';

  @override
  String get gameTabSimilar => 'Similar';

  @override
  String get gameLandscape => 'Landscape';

  @override
  String get gamePortrait => 'Portrait';

  @override
  String get gamePlayNow => 'Play Now';

  @override
  String get gameNotAvailable => 'Not available';

  @override
  String gamePlaySemantics(String title) {
    return 'Play $title';
  }

  @override
  String get gameNoDescription => 'No description yet.';

  @override
  String get gameDefaultInstructions =>
      'Just tap Play Now and follow the in-game tutorial.';

  @override
  String get gameNoReviews => 'No reviews yet. Be the first after you play!';

  @override
  String get gameSimilarGames => 'Similar Games';

  @override
  String get gameNoSimilar => 'No similar games found.';

  @override
  String get gameNoRatings => 'No ratings yet';

  @override
  String gameReviewCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '($countString reviews)',
      one: '(1 review)',
    );
    return '$_temp0';
  }

  @override
  String gameByDeveloper(String developer) {
    return 'by $developer';
  }

  @override
  String gameShareText(String title, String url) {
    return 'Play $title on GameDiscoveries: $url';
  }

  @override
  String get playerLoadFailed => 'The game could not be loaded.';

  @override
  String get playerUnsupported => 'This game is not available on mobile yet.';

  @override
  String get playerUnavailableTitle => 'Game unavailable';

  @override
  String get playerPause => 'Pause';

  @override
  String get playerPaused => 'Paused';

  @override
  String get playerResume => 'Resume';

  @override
  String get playerRestart => 'Restart';

  @override
  String get playerExit => 'Exit Game';

  @override
  String get communityTitle => 'Community';

  @override
  String get communitySignInToPost => 'Sign in to post in the community.';

  @override
  String get communitySignInToLike => 'Sign in to like posts.';

  @override
  String get communitySignInToReport => 'Sign in to report posts.';

  @override
  String get communitySignInToComment => 'Sign in to join the conversation.';

  @override
  String get communityShareFallbackTitle => 'a community post';

  @override
  String communityShareText(String title, String url) {
    return 'Check out \"$title\" on GameDiscoveries: $url';
  }

  @override
  String get communitySavedToPosts => 'Saved to your posts.';

  @override
  String get communityRemovedFromSaved => 'Removed from saved.';

  @override
  String get communitySharePost => 'Share post';

  @override
  String get communitySavePost => 'Save post';

  @override
  String get communityRemoveFromSaved => 'Remove from saved';

  @override
  String get communityReportPost => 'Report post';

  @override
  String get communityDeletePost => 'Delete post';

  @override
  String get communityMoreOptions => 'More options';

  @override
  String get communityReportTitle => 'Why are you reporting this?';

  @override
  String get communityReportSpam => 'Spam';

  @override
  String get communityReportHarassment => 'Harassment';

  @override
  String get communityReportMisleading => 'Misleading';

  @override
  String get communityReportOther => 'Something else';

  @override
  String get communityReportThanks => 'Thanks, we\'ll review this post.';

  @override
  String get communityDeletePostTitle => 'Delete post?';

  @override
  String get communityDeletePostMessage =>
      'Your post and its comments will be removed.';

  @override
  String get communityPostDeleted => 'Post deleted.';

  @override
  String communityInSection(String section) {
    return 'in $section';
  }

  @override
  String get communitySectionDiscussions => 'Discussions';

  @override
  String get communitySectionQuestions => 'Questions';

  @override
  String get communitySectionRecommendations => 'Recommendations';

  @override
  String get communitySectionGameShares => 'Game Shares';

  @override
  String get communitySectionAchievements => 'Achievements';

  @override
  String communityOpenGame(String title) {
    return 'Open $title';
  }

  @override
  String communityLikesSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count likes',
      one: '1 like',
    );
    return '$_temp0';
  }

  @override
  String get communityLikePost => 'Like post';

  @override
  String get communityUnlikePost => 'Unlike post';

  @override
  String get communityLike => 'Like';

  @override
  String get communityLiked => 'Liked';

  @override
  String get communitySearchPosts => 'Search posts';

  @override
  String get communityCloseSearch => 'Close search';

  @override
  String get communitySavedPostsTooltip => 'Saved posts';

  @override
  String get communitySavedPostsTitle => 'Saved Posts';

  @override
  String get communityNewPostTooltip => 'New post';

  @override
  String get communityNewPostTitle => 'New Post';

  @override
  String get communitySortLatest => 'Latest';

  @override
  String get communitySortTrending => 'Trending';

  @override
  String get communitySortMostLiked => 'Most Liked';

  @override
  String get communityEmptyTitle => 'Nothing here yet';

  @override
  String get communityEmptyMessage =>
      'Start the conversation with the + button.';

  @override
  String get communityNoResultsTitle => 'No posts found';

  @override
  String communityNoResultsMessage(String query) {
    return 'Nothing matches \"$query\". Try another word.';
  }

  @override
  String get communityNoSavedTitle => 'No saved posts';

  @override
  String get communityNoSavedMessage =>
      'Tap the bookmark on a post to keep it here.';

  @override
  String get communityComposerRequired => 'Title and message are required.';

  @override
  String get communityTypeDiscussion => 'Discussion';

  @override
  String get communityTypeQuestion => 'Question';

  @override
  String get communityTitleHint => 'Title';

  @override
  String get communityContentHint => 'Share something with the community...';

  @override
  String get communityPublish => 'Post';

  @override
  String get communityPostTitle => 'Post';

  @override
  String get communityDeleteCommentTitle => 'Delete comment?';

  @override
  String get communityDeleteCommentMessage => 'Your comment will be removed.';

  @override
  String get communityCommentDeleted => 'Comment deleted.';

  @override
  String communityComments(int count) {
    return 'Comments ($count)';
  }

  @override
  String get communityNoComments => 'No comments yet. Start the conversation!';

  @override
  String get communityReply => 'Reply';

  @override
  String communityReplyingTo(String name) {
    return 'Replying to $name';
  }

  @override
  String get communityCancelReply => 'Cancel reply';

  @override
  String get communityWriteComment => 'Write a comment...';

  @override
  String get communityWriteReply => 'Write a reply...';

  @override
  String get communitySendComment => 'Send comment';

  @override
  String get favoritesSignInTitle => 'Save your favorites';

  @override
  String get favoritesSignInMessage =>
      'Sign in to keep a list of games you love.';

  @override
  String get favoritesEmptyTitle => 'No favorites yet';

  @override
  String get favoritesEmptyMessage =>
      'Tap the heart on any game to save it here.';

  @override
  String get favoritesDiscoverGames => 'Discover Games';

  @override
  String get favoritesAdd => 'Add to favorites';

  @override
  String get favoritesRemove => 'Remove from favorites';

  @override
  String get favoritesSignInPrompt => 'Sign in to save your favorite games.';

  @override
  String get historySignInTitle => 'Your play history';

  @override
  String get historySignInMessage =>
      'Sign in to pick up right where you left off.';

  @override
  String get historyEmptyTitle => 'Nothing played yet';

  @override
  String get historyEmptyMessage => 'Games you play will show up here.';

  @override
  String historyPlayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plays',
      one: '1 play',
    );
    return '$_temp0';
  }

  @override
  String get historyContinuePlaying => 'Continue Playing';

  @override
  String get historyRecentlyPlayed => 'Recently Played';

  @override
  String get historyContinue => 'Continue';

  @override
  String historyPlayedOn(String platform) {
    return 'on $platform';
  }

  @override
  String historyTotalTime(String time) {
    return '$time total';
  }

  @override
  String get reviewsSignInTitle => 'Your reviews';

  @override
  String get reviewsSignInMessage =>
      'Sign in to see and manage the reviews you wrote.';

  @override
  String get reviewsEmptyTitle => 'No reviews yet';

  @override
  String get reviewsEmptyMessage =>
      'Play a game, then share what you think on its page.';

  @override
  String get reviewsDeleteTitle => 'Delete review?';

  @override
  String reviewsDeleteMessage(String game) {
    return 'Your review of $game will be removed.';
  }

  @override
  String get reviewsDeleted => 'Review deleted';

  @override
  String get reviewsDeleteTooltip => 'Delete review';

  @override
  String reviewsRatedSemantics(int rating) {
    return 'Rated $rating out of 5';
  }

  @override
  String get reviewsHidden => 'Hidden by moderators';

  @override
  String get missionsSignInTitle => 'Daily & weekly missions';

  @override
  String get missionsSignInMessage =>
      'Sign in to get missions, earn bonus XP and keep your streak alive.';

  @override
  String get missionsDaily => 'Daily';

  @override
  String get missionsWeekly => 'Weekly';

  @override
  String get missionsEmpty => 'No missions right now. New ones arrive soon.';

  @override
  String get missionsCompleteDaily => 'Complete Daily Missions';

  @override
  String get missionsCompleteWeekly => 'Complete Weekly Missions';

  @override
  String missionsEarnUpTo(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'Earn up to $xpString XP';
  }

  @override
  String get missionsCompletedSemantics => 'Missions completed';

  @override
  String get achievementsSignInTitle => 'Unlock achievements';

  @override
  String get achievementsSignInMessage =>
      'Sign in to collect badges as you play and explore.';

  @override
  String achievementsUnlockedOf(int total) {
    return ' / $total Unlocked';
  }

  @override
  String get achievementsUnlockedSemantics => 'Achievements unlocked';

  @override
  String get achievementsEmptyCategory =>
      'No achievements in this category yet.';

  @override
  String get achievementsSecretSemantics => 'Secret achievement';

  @override
  String get achievementsSecretTitle => 'Secret Achievement';

  @override
  String get achievementsSecretHint => 'Keep playing to discover this one.';

  @override
  String achievementsUnlockedAt(String time) {
    return 'Unlocked $time';
  }

  @override
  String get achievementsLocked => 'Locked';

  @override
  String achievementsProgress(int current, int target) {
    return 'Progress $current/$target';
  }

  @override
  String get progressSignInTitle => 'Track your progress';

  @override
  String get progressSignInMessage =>
      'Sign in to earn XP, level up and build your streak.';

  @override
  String get progressLevelBadge => 'Lv';

  @override
  String get progressMaxLevelReached => 'Max level reached';

  @override
  String progressStreakDays(int days) {
    return '${days}d';
  }

  @override
  String get progressGamesPlayedLabel => 'Games Played';

  @override
  String get progressRecentXp => 'Recent XP Activity';

  @override
  String get progressNoXp => 'Play a game to start earning XP.';

  @override
  String get progressXpEarned => 'XP earned';

  @override
  String get leaderboardEmptyTitle => 'No rankings yet';

  @override
  String get leaderboardEmptyMessage =>
      'Play games to be the first on the board!';

  @override
  String get leaderboardScopeGlobal => 'Global';

  @override
  String get leaderboardScopeWeekly => 'Weekly';

  @override
  String get leaderboardScopeMonthly => 'Monthly';

  @override
  String leaderboardSeasonEndsIn(String time) {
    return 'Season ends in $time';
  }

  @override
  String leaderboardPodiumSemantics(int rank, String name, int score) {
    final intl.NumberFormat scoreNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String scoreString = scoreNumberFormat.format(score);

    return 'Rank $rank, $name, $scoreString XP';
  }

  @override
  String leaderboardRowSemantics(
    int rank,
    String name,
    String detail,
    int score,
  ) {
    final intl.NumberFormat scoreNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String scoreString = scoreNumberFormat.format(score);

    return 'Rank $rank, $name, $detail, $scoreString XP';
  }

  @override
  String get leaderboardPlayToRank => 'Play a game to get ranked.';

  @override
  String get leaderboardSignInToRank => 'Sign in to see your rank.';
}
