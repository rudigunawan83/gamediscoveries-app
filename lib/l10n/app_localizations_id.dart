// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get navigationHome => 'Beranda';

  @override
  String get navigationDiscover => 'Jelajahi';

  @override
  String get navigationPlay => 'Main';

  @override
  String get navigationMissions => 'Misi';

  @override
  String get navigationProfile => 'Profil';

  @override
  String get commonRetry => 'Coba lagi';

  @override
  String get commonCancel => 'Batal';

  @override
  String get commonDelete => 'Hapus';

  @override
  String get commonSignIn => 'Masuk';

  @override
  String get commonCreateAccount => 'Buat akun';

  @override
  String get commonLoading => 'Memuat…';

  @override
  String get commonBack => 'Kembali';

  @override
  String get commonNext => 'Lanjut';

  @override
  String get commonSkip => 'Lewati';

  @override
  String get commonSeeAll => 'Lihat Semua';

  @override
  String get commonSearchGames => 'Cari game...';

  @override
  String get commonClearSearch => 'Hapus pencarian';

  @override
  String get commonMobileBadge => 'Mobile';

  @override
  String get commonSoon => 'Segera';

  @override
  String get commonSignOut => 'Keluar';

  @override
  String get settingsTitle => 'Pengaturan Akun';

  @override
  String get settingsLanguage => 'Bahasa';

  @override
  String get settingsLanguageSubtitle => 'Pilih bahasa yang kamu inginkan';

  @override
  String get settingsSystemDefault => 'Default sistem';

  @override
  String get settingsEnglish => 'English';

  @override
  String get settingsIndonesian => 'Bahasa Indonesia';

  @override
  String get settingsLanguageChanged => 'Bahasa diperbarui';

  @override
  String get settingsManageAccountTitle => 'Kelola akunmu';

  @override
  String get settingsManageAccountMessage =>
      'Masuk untuk melihat dan mengelola akunmu.';

  @override
  String get settingsDisplayName => 'Nama tampilan';

  @override
  String get settingsUsername => 'Nama pengguna';

  @override
  String get settingsEmail => 'Email';

  @override
  String get settingsDisplayNameHint =>
      'Nama yang dilihat orang lain. 2–40 karakter.';

  @override
  String get settingsDisplayNameInvalid => 'Gunakan 2–40 karakter.';

  @override
  String get settingsUsernameHint =>
      'Huruf, angka, atau tanda hubung. 3–30 karakter.';

  @override
  String get settingsUsernameInvalid =>
      'Gunakan 3–30 huruf, angka, atau tanda hubung.';

  @override
  String get settingsUsernameTaken => 'Nama pengguna itu sudah dipakai.';

  @override
  String get settingsSave => 'Simpan profil';

  @override
  String get settingsSaving => 'Menyimpan…';

  @override
  String get settingsProfileSaved => 'Profil diperbarui';

  @override
  String get settingsPrivacy => 'Privasi';

  @override
  String get settingsPrivacyShowFavorites => 'Tampilkan favorit';

  @override
  String get settingsPrivacyShowFavoritesHint =>
      'Orang lain bisa melihat game yang kamu simpan.';

  @override
  String get settingsPrivacyShowHistory => 'Tampilkan riwayat main';

  @override
  String get settingsPrivacyShowHistoryHint =>
      'Orang lain bisa melihat game yang baru kamu mainkan.';

  @override
  String get settingsPrivacyShowAchievements => 'Tampilkan pencapaian';

  @override
  String get settingsPrivacyShowAchievementsHint =>
      'Orang lain bisa melihat lencana yang kamu buka.';

  @override
  String get settingsPrivacyShowActivity => 'Tampilkan aktivitas';

  @override
  String get settingsPrivacyShowActivityHint =>
      'Aktivitasmu muncul di feed komunitas.';

  @override
  String get settingsPrivacyShowOnLeaderboards => 'Tampil di papan peringkat';

  @override
  String get settingsPrivacyShowOnLeaderboardsHint =>
      'Peringkatmu terlihat di papan peringkat publik.';

  @override
  String get authLoginTitle => 'Selamat datang kembali';

  @override
  String get authLoginSubtitle =>
      'Masuk untuk menyimpan XP, streak, dan pencapaianmu.';

  @override
  String get authRegisterTitle => 'Buat akunmu';

  @override
  String get authRegisterSubtitle =>
      'Kumpulkan XP, buka pencapaian, dan bersaing dengan pemain lain.';

  @override
  String get authCreateAccount => 'Buat Akun';

  @override
  String get authEmailHint => 'Email';

  @override
  String get authPasswordHint => 'Kata sandi';

  @override
  String get authDisplayNameHint => 'Nama tampilan';

  @override
  String get authShowPassword => 'Tampilkan kata sandi';

  @override
  String get authHidePassword => 'Sembunyikan kata sandi';

  @override
  String get authEmailRequired => 'Email wajib diisi.';

  @override
  String get authEmailInvalid => 'Masukkan email yang valid.';

  @override
  String get authPasswordRequired => 'Kata sandi wajib diisi.';

  @override
  String authMinCharacters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gunakan minimal $count karakter.',
    );
    return '$_temp0';
  }

  @override
  String get authInvalidCredentials => 'Email atau kata sandi salah.';

  @override
  String get authEmailTaken => 'Akun dengan email ini sudah terdaftar.';

  @override
  String get authNoAccount => 'Belum punya akun? Buat sekarang';

  @override
  String get authHaveAccount => 'Sudah punya akun? Masuk';

  @override
  String get onboardingSlide1Word1 => 'Temukan';

  @override
  String get onboardingSlide1Word2 => 'Mainkan';

  @override
  String get onboardingSlide1Word3 => 'Berkembang';

  @override
  String get onboardingSlide1Body =>
      'Ribuan game instan pilihan untukmu. Tanpa unduhan, cukup ketuk dan main.';

  @override
  String get onboardingSlide2Word1 => 'Kumpulkan';

  @override
  String get onboardingSlide2Word2 => 'Naik Level';

  @override
  String get onboardingSlide2Word3 => 'Bersaing';

  @override
  String get onboardingSlide2Body =>
      'Dapatkan XP setiap kali bermain, selesaikan misi harian, jaga streak, dan naiki papan peringkat.';

  @override
  String get onboardingSlide3Word1 => 'Main';

  @override
  String get onboardingSlide3Word2 => 'Berbagi';

  @override
  String get onboardingSlide3Word3 => 'Terhubung';

  @override
  String get onboardingSlide3Body =>
      'Gabung komunitas gamer, temukan game baru, raih hadiah, dan dapatkan teman baru!';

  @override
  String get onboardingGetStarted => 'Mulai';

  @override
  String get onboardingHaveAccount => 'Saya sudah punya akun';

  @override
  String onboardingPageIndicator(int page, int count) {
    return 'Halaman $page dari $count';
  }

  @override
  String get timeJustNow => 'baru saja';

  @override
  String timeMinutesAgo(int count) {
    return '$count mnt lalu';
  }

  @override
  String timeHoursAgo(int count) {
    return '$count jam lalu';
  }

  @override
  String timeDaysAgo(int count) {
    return '$count hr lalu';
  }

  @override
  String timeDays(int count) {
    return '$count hr';
  }

  @override
  String timeHours(int count) {
    return '$count j';
  }

  @override
  String timeMinutes(int count) {
    return '$count mnt';
  }

  @override
  String get timeUnderMinute => '<1 mnt';

  @override
  String timeLeft(String time) {
    return 'sisa $time';
  }

  @override
  String get timeExpired => 'Berakhir';

  @override
  String get errorOffline =>
      'Kamu sedang offline atau koneksi tidak stabil. Silakan coba lagi.';

  @override
  String get errorSessionExpired =>
      'Sesimu telah berakhir. Silakan masuk lagi.';

  @override
  String get errorForbidden => 'Kamu tidak punya akses ke konten ini.';

  @override
  String get errorNotFound => 'Konten tidak ditemukan.';

  @override
  String get errorTooManyRequests =>
      'Terlalu banyak permintaan. Coba lagi sebentar lagi.';

  @override
  String get errorServer =>
      'Server kami sedang bermasalah. Silakan coba lagi nanti.';

  @override
  String get errorGeneric => 'Terjadi kesalahan. Silakan coba lagi.';

  @override
  String get notificationsMarkAllRead => 'Tandai semua dibaca';

  @override
  String get notificationsSignInTitle => 'Tetap terhubung';

  @override
  String get notificationsSignInMessage =>
      'Masuk untuk dapat kabar soal pencapaian, misi, dan balasan.';

  @override
  String get notificationsEmpty => 'Semua notifikasi sudah kamu baca.';

  @override
  String get notificationsFallbackTitle => 'Notifikasi';

  @override
  String get notificationsTypeCommentOnPost => 'Komentar Baru';

  @override
  String get notificationsTypeReplyToComment => 'Balasan Baru';

  @override
  String get notificationsTypeUserFollowed => 'Pengikut Baru';

  @override
  String get notificationsTypeAchievementUnlocked => 'Pencapaian Terbuka';

  @override
  String get notificationsTypePostCreated => 'Postingan Baru';

  @override
  String get adRewardTitle => 'Tonton & Raih XP';

  @override
  String adRewardAvailable(int xp, int remaining, int limit) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'Tonton video singkat untuk +$xpString XP · sisa $remaining/$limit hari ini';
  }

  @override
  String adRewardExhausted(int limit) {
    return 'Semua $limit video sudah ditonton. Kembali lagi besok!';
  }

  @override
  String get adRewardUnavailable => 'Video berhadiah tidak tersedia.';

  @override
  String get adRewardNoVideo => 'Belum ada video saat ini.';

  @override
  String get adRewardShowFailed => 'Video tidak dapat ditampilkan.';

  @override
  String get adRewardNotCompleted =>
      'Tonton videonya sampai selesai untuk dapat XP.';

  @override
  String adRewardGranted(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return '+$xpString XP ditambahkan!';
  }

  @override
  String adRewardPending(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'Terima kasih! +$xpString XP akan masuk setelah tayangan diverifikasi.';
  }

  @override
  String get adRewardDailyLimit =>
      'Jatah video berhadiah hari ini sudah habis.';

  @override
  String get adRewardDailyXpCap =>
      'Batas XP harian tercapai, kali ini tidak ada XP.';

  @override
  String get adRewardExpired => 'Waktunya habis. Silakan coba lagi.';

  @override
  String get adRewardUnverified => 'Tayangan ini tidak dapat diverifikasi.';

  @override
  String updateAvailable(String version) {
    return 'Pembaruan tersedia: v$version';
  }

  @override
  String get updateLater => 'Nanti';

  @override
  String get updateAction => 'Perbarui';

  @override
  String get updateRequiredTitle => 'Pembaruan wajib';

  @override
  String updateRequiredMessage(String version) {
    return 'Versi GameDiscoveries ini sudah tidak didukung. Perbarui ke v$version untuk terus bermain.';
  }

  @override
  String get updateOpening => 'Membuka…';

  @override
  String get updateNow => 'Perbarui sekarang';

  @override
  String get splashTagline => 'Temukan. Main. Naik Level.';

  @override
  String get splashLoading => 'Menyiapkan petualangan berikutnya...';

  @override
  String progressGamesPlayed(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString game dimainkan',
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
  String get progressCurrentStreak => 'Streak Saat Ini';

  @override
  String profileWelcome(String username) {
    return 'Selamat datang, $username';
  }

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileDefaultName => 'Pemain';

  @override
  String get profileGuestName => 'Pemain Tamu';

  @override
  String get profileGuestPrompt =>
      'Buat akun untuk menyimpan XP, streak, favorit, dan pencapaian.';

  @override
  String get profileMyProgress => 'Progres Saya';

  @override
  String get profileAchievements => 'Pencapaian';

  @override
  String get profileMyFavorites => 'Favorit Saya';

  @override
  String get profilePlayHistory => 'Riwayat Main';

  @override
  String get profileMyReviews => 'Ulasan Saya';

  @override
  String get profileHelpSupport => 'Bantuan & Dukungan';

  @override
  String get profileLeaderboard => 'Papan Peringkat';

  @override
  String get profileCommunity => 'Komunitas';

  @override
  String get profileNotifications => 'Notifikasi';

  @override
  String get profileMore => 'Lainnya';

  @override
  String get profileStatGames => 'Game';

  @override
  String get profileStatPoints => 'Poin';

  @override
  String get profileStatSessionsSemantics => 'Sesi game yang dimainkan';

  @override
  String get profileStatUniqueGamesSemantics => 'Game berbeda yang dimainkan';

  @override
  String get profileStatAchievementsSemantics => 'Pencapaian yang terbuka';

  @override
  String get profileStatPointsSemantics => 'Total poin XP';

  @override
  String profileStatUnavailableSemantics(String label) {
    return '$label: tidak tersedia';
  }

  @override
  String get profileLevelUnknown => 'Level —';

  @override
  String get profileMaxLevel => 'LEVEL MAKS';

  @override
  String get profileLevelLoadingSemantics => 'Memuat progres level';

  @override
  String profileLevelMaxSemantics(int level) {
    return 'Level $level, level maksimum tercapai';
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

    return 'Level $level, $currentString dari $nextString XP';
  }

  @override
  String get profileChangeAvatar => 'Ganti avatar';

  @override
  String get profileUploadingAvatar => 'Mengunggah avatar';

  @override
  String get profileChooseFromGallery => 'Pilih dari galeri';

  @override
  String get profileTakePhoto => 'Ambil foto';

  @override
  String get profileRemovePhoto => 'Hapus foto';

  @override
  String get profileAvatarUpdated => 'Avatar diperbarui.';

  @override
  String get profileAvatarRemoved => 'Avatar dihapus.';

  @override
  String get profileAvatarPermissionError =>
      'Tidak bisa membuka kamera atau galeri. Periksa izin aplikasi.';

  @override
  String profileAvatarTooLarge(int maxMb) {
    return 'Ukuran gambar maksimal $maxMb MB.';
  }

  @override
  String get signOutTitle => 'Keluar dari akun?';

  @override
  String get signOutMessage => 'Progresmu tetap tersimpan di akunmu.';

  @override
  String get helpFaqEarnXpQuestion => 'Bagaimana cara mendapatkan XP?';

  @override
  String get helpFaqEarnXpAnswer =>
      'Mainkan game, selesaikan misi, dan buka pencapaian saat sudah masuk. XP diberikan oleh server kami, jadi mungkin perlu sesaat sebelum muncul di profilmu.';

  @override
  String get helpFaqProgressQuestion => 'Kenapa progresku tidak tersimpan?';

  @override
  String get helpFaqProgressAnswer =>
      'XP, streak, favorit, dan pencapaian hanya tersimpan ke akunmu saat kamu sudah masuk.';

  @override
  String get helpFaqMissionsQuestion => 'Apa itu misi?';

  @override
  String get helpFaqMissionsAnswer =>
      'Misi adalah tantangan yang diperbarui secara berkala. Buka tab Misi untuk melihat misi yang aktif dan berapa XP hadiahnya.';

  @override
  String get helpFaqGameLoadQuestion =>
      'Game tidak mau terbuka. Apa yang bisa saya lakukan?';

  @override
  String get helpFaqGameLoadAnswer =>
      'Game disediakan oleh penerbit pihak ketiga dan butuh koneksi internet yang stabil. Kembali lalu buka game lagi, atau coba game lain.';

  @override
  String get helpFaqSignOutQuestion => 'Bagaimana cara keluar?';

  @override
  String get helpFaqSignOutAnswer =>
      'Buka Pengaturan Akun dari profilmu, lalu ketuk Keluar.';

  @override
  String profileComingSoonSemantics(String label) {
    return '$label, segera hadir';
  }

  @override
  String get commonAll => 'Semua';

  @override
  String get commonShare => 'Bagikan';

  @override
  String get commonNotifications => 'Notifikasi';

  @override
  String get commonYou => 'Kamu';

  @override
  String get commonFindGame => 'Cari Game';

  @override
  String get commonMaxShort => 'MAKS';

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
    return 'Hai, $name 👋';
  }

  @override
  String get homeSignInPrompt => 'Masuk untuk dapat XP & naik level';

  @override
  String get homeLevelProgressSemantics => 'Progres level';

  @override
  String get homeBannerSemantics =>
      'Petualangan Baru Setiap Hari. Jelajahi game terbaru dan paling tren!';

  @override
  String get homeEmpty => 'Belum ada game untuk ditampilkan. Cek lagi nanti.';

  @override
  String get homeShelfRecommended => 'Rekomendasi Untukmu';

  @override
  String get homeShelfTrending => 'Sedang Tren';

  @override
  String get homeShelfMobile => 'Dibuat untuk Ponsel';

  @override
  String get homeShelfPopular => 'Populer';

  @override
  String get homeShelfNewReleases => 'Rilis Baru';

  @override
  String get homeShelfHot => 'Game Hot';

  @override
  String get homeShelfMostPlayed => 'Paling Banyak Dimainkan';

  @override
  String get homeShelfBest => 'Game Terbaik';

  @override
  String get homeShelfMultiplayer => 'Multipemain';

  @override
  String get homeShelfExclusive => 'Eksklusif';

  @override
  String get homeFeaturedBadge => 'UNGGULAN';

  @override
  String homeFeaturedSemantics(String title) {
    return 'Unggulan: $title';
  }

  @override
  String get playQuickPlay => 'Main Cepat';

  @override
  String get playEmpty => 'Belum ada pilihan main cepat saat ini.';

  @override
  String get playNowTooltip => 'Main sekarang';

  @override
  String get discoverSortTrending => 'Tren';

  @override
  String get discoverSortNew => 'Terbaru';

  @override
  String get discoverSortPopular => 'Populer';

  @override
  String get discoverSortAz => 'A–Z';

  @override
  String get discoverNoResultsTitle => 'Game tidak ditemukan';

  @override
  String get discoverNoResultsMessage => 'Coba kata kunci atau kategori lain.';

  @override
  String get gameTabAbout => 'Tentang';

  @override
  String get gameTabHowToPlay => 'Cara Main';

  @override
  String get gameTabReviews => 'Ulasan';

  @override
  String get gameTabSimilar => 'Serupa';

  @override
  String get gameLandscape => 'Lanskap';

  @override
  String get gamePortrait => 'Potret';

  @override
  String get gamePlayNow => 'Main Sekarang';

  @override
  String get gameNotAvailable => 'Tidak tersedia';

  @override
  String gamePlaySemantics(String title) {
    return 'Mainkan $title';
  }

  @override
  String get gameNoDescription => 'Belum ada deskripsi.';

  @override
  String get gameDefaultInstructions =>
      'Ketuk Main Sekarang dan ikuti tutorial di dalam game.';

  @override
  String get gameNoReviews =>
      'Belum ada ulasan. Jadilah yang pertama setelah bermain!';

  @override
  String get gameSimilarGames => 'Game Serupa';

  @override
  String get gameNoSimilar => 'Tidak ada game serupa.';

  @override
  String get gameNoRatings => 'Belum ada rating';

  @override
  String gameReviewCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '($countString ulasan)',
    );
    return '$_temp0';
  }

  @override
  String gameByDeveloper(String developer) {
    return 'oleh $developer';
  }

  @override
  String gameShareText(String title, String url) {
    return 'Mainkan $title di GameDiscoveries: $url';
  }

  @override
  String get playerLoadFailed => 'Game tidak dapat dimuat.';

  @override
  String get playerUnsupported => 'Game ini belum tersedia di ponsel.';

  @override
  String get playerUnavailableTitle => 'Game tidak tersedia';

  @override
  String get playerPause => 'Jeda';

  @override
  String get playerPaused => 'Dijeda';

  @override
  String get playerResume => 'Lanjutkan';

  @override
  String get playerRestart => 'Mulai Ulang';

  @override
  String get playerExit => 'Keluar Game';

  @override
  String get communityTitle => 'Komunitas';

  @override
  String get communitySignInToPost =>
      'Masuk untuk membuat postingan di komunitas.';

  @override
  String get communitySignInToLike => 'Masuk untuk menyukai postingan.';

  @override
  String get communitySignInToReport => 'Masuk untuk melaporkan postingan.';

  @override
  String get communitySignInToComment => 'Masuk untuk ikut berdiskusi.';

  @override
  String get communityShareFallbackTitle => 'sebuah postingan komunitas';

  @override
  String communityShareText(String title, String url) {
    return 'Lihat \"$title\" di GameDiscoveries: $url';
  }

  @override
  String get communitySavedToPosts => 'Disimpan ke postinganmu.';

  @override
  String get communityRemovedFromSaved => 'Dihapus dari tersimpan.';

  @override
  String get communitySharePost => 'Bagikan postingan';

  @override
  String get communitySavePost => 'Simpan postingan';

  @override
  String get communityRemoveFromSaved => 'Hapus dari tersimpan';

  @override
  String get communityReportPost => 'Laporkan postingan';

  @override
  String get communityDeletePost => 'Hapus postingan';

  @override
  String get communityMoreOptions => 'Opsi lainnya';

  @override
  String get communityReportTitle => 'Kenapa kamu melaporkan ini?';

  @override
  String get communityReportSpam => 'Spam';

  @override
  String get communityReportHarassment => 'Pelecehan';

  @override
  String get communityReportMisleading => 'Menyesatkan';

  @override
  String get communityReportOther => 'Lainnya';

  @override
  String get communityReportThanks =>
      'Terima kasih, kami akan meninjau postingan ini.';

  @override
  String get communityDeletePostTitle => 'Hapus postingan?';

  @override
  String get communityDeletePostMessage =>
      'Postingan dan komentarnya akan dihapus.';

  @override
  String get communityPostDeleted => 'Postingan dihapus.';

  @override
  String communityInSection(String section) {
    return 'di $section';
  }

  @override
  String get communitySectionDiscussions => 'Diskusi';

  @override
  String get communitySectionQuestions => 'Pertanyaan';

  @override
  String get communitySectionRecommendations => 'Rekomendasi';

  @override
  String get communitySectionGameShares => 'Berbagi Game';

  @override
  String get communitySectionAchievements => 'Pencapaian';

  @override
  String communityOpenGame(String title) {
    return 'Buka $title';
  }

  @override
  String communityLikesSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suka',
    );
    return '$_temp0';
  }

  @override
  String get communityLikePost => 'Sukai postingan';

  @override
  String get communityUnlikePost => 'Batal sukai postingan';

  @override
  String get communityLike => 'Suka';

  @override
  String get communityLiked => 'Disukai';

  @override
  String get communitySearchPosts => 'Cari postingan';

  @override
  String get communityCloseSearch => 'Tutup pencarian';

  @override
  String get communitySavedPostsTooltip => 'Postingan tersimpan';

  @override
  String get communitySavedPostsTitle => 'Postingan Tersimpan';

  @override
  String get communityNewPostTooltip => 'Postingan baru';

  @override
  String get communityNewPostTitle => 'Postingan Baru';

  @override
  String get communitySortLatest => 'Terbaru';

  @override
  String get communitySortTrending => 'Tren';

  @override
  String get communitySortMostLiked => 'Paling Disukai';

  @override
  String get communityEmptyTitle => 'Belum ada apa-apa';

  @override
  String get communityEmptyMessage => 'Mulai percakapan dengan tombol +.';

  @override
  String get communityNoResultsTitle => 'Postingan tidak ditemukan';

  @override
  String communityNoResultsMessage(String query) {
    return 'Tidak ada yang cocok dengan \"$query\". Coba kata lain.';
  }

  @override
  String get communityNoSavedTitle => 'Belum ada postingan tersimpan';

  @override
  String get communityNoSavedMessage =>
      'Ketuk ikon bookmark pada postingan untuk menyimpannya di sini.';

  @override
  String get communityComposerRequired => 'Judul dan pesan wajib diisi.';

  @override
  String get communityTypeDiscussion => 'Diskusi';

  @override
  String get communityTypeQuestion => 'Pertanyaan';

  @override
  String get communityTitleHint => 'Judul';

  @override
  String get communityContentHint => 'Bagikan sesuatu dengan komunitas...';

  @override
  String get communityPublish => 'Kirim';

  @override
  String get communityPostTitle => 'Postingan';

  @override
  String get communityDeleteCommentTitle => 'Hapus komentar?';

  @override
  String get communityDeleteCommentMessage => 'Komentarmu akan dihapus.';

  @override
  String get communityCommentDeleted => 'Komentar dihapus.';

  @override
  String communityComments(int count) {
    return 'Komentar ($count)';
  }

  @override
  String get communityNoComments => 'Belum ada komentar. Mulai percakapan!';

  @override
  String get communityReply => 'Balas';

  @override
  String communityReplyingTo(String name) {
    return 'Membalas $name';
  }

  @override
  String get communityCancelReply => 'Batal membalas';

  @override
  String get communityWriteComment => 'Tulis komentar...';

  @override
  String get communityWriteReply => 'Tulis balasan...';

  @override
  String get communitySendComment => 'Kirim komentar';

  @override
  String get favoritesSignInTitle => 'Simpan game favoritmu';

  @override
  String get favoritesSignInMessage =>
      'Masuk untuk menyimpan daftar game yang kamu suka.';

  @override
  String get favoritesEmptyTitle => 'Belum ada favorit';

  @override
  String get favoritesEmptyMessage =>
      'Ketuk ikon hati pada game untuk menyimpannya di sini.';

  @override
  String get favoritesDiscoverGames => 'Jelajahi Game';

  @override
  String get favoritesAdd => 'Tambah ke favorit';

  @override
  String get favoritesRemove => 'Hapus dari favorit';

  @override
  String get favoritesSignInPrompt => 'Masuk untuk menyimpan game favoritmu.';

  @override
  String get historySignInTitle => 'Riwayat mainmu';

  @override
  String get historySignInMessage =>
      'Masuk untuk melanjutkan dari terakhir kali kamu bermain.';

  @override
  String get historyEmptyTitle => 'Belum ada yang dimainkan';

  @override
  String get historyEmptyMessage =>
      'Game yang kamu mainkan akan muncul di sini.';

  @override
  String historyPlayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kali main',
    );
    return '$_temp0';
  }

  @override
  String get historyContinuePlaying => 'Lanjutkan Bermain';

  @override
  String get historyRecentlyPlayed => 'Baru Dimainkan';

  @override
  String get historyContinue => 'Lanjutkan';

  @override
  String historyPlayedOn(String platform) {
    return 'di $platform';
  }

  @override
  String historyTotalTime(String time) {
    return 'total $time';
  }

  @override
  String get reviewsSignInTitle => 'Ulasanmu';

  @override
  String get reviewsSignInMessage =>
      'Masuk untuk melihat dan mengelola ulasan yang kamu tulis.';

  @override
  String get reviewsEmptyTitle => 'Belum ada ulasan';

  @override
  String get reviewsEmptyMessage =>
      'Mainkan game, lalu bagikan pendapatmu di halamannya.';

  @override
  String get reviewsDeleteTitle => 'Hapus ulasan?';

  @override
  String reviewsDeleteMessage(String game) {
    return 'Ulasanmu untuk $game akan dihapus.';
  }

  @override
  String get reviewsDeleted => 'Ulasan dihapus';

  @override
  String get reviewsDeleteTooltip => 'Hapus ulasan';

  @override
  String reviewsRatedSemantics(int rating) {
    return 'Rating $rating dari 5';
  }

  @override
  String get reviewsHidden => 'Disembunyikan oleh moderator';

  @override
  String get missionsSignInTitle => 'Misi harian & mingguan';

  @override
  String get missionsSignInMessage =>
      'Masuk untuk mendapatkan misi, bonus XP, dan menjaga streak-mu.';

  @override
  String get missionsDaily => 'Harian';

  @override
  String get missionsWeekly => 'Mingguan';

  @override
  String get missionsEmpty =>
      'Belum ada misi saat ini. Misi baru segera hadir.';

  @override
  String get missionsCompleteDaily => 'Selesaikan Misi Harian';

  @override
  String get missionsCompleteWeekly => 'Selesaikan Misi Mingguan';

  @override
  String missionsEarnUpTo(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'Dapatkan hingga $xpString XP';
  }

  @override
  String get missionsCompletedSemantics => 'Misi selesai';

  @override
  String get achievementsSignInTitle => 'Buka pencapaian';

  @override
  String get achievementsSignInMessage =>
      'Masuk untuk mengumpulkan lencana saat bermain dan menjelajah.';

  @override
  String achievementsUnlockedOf(int total) {
    return ' / $total Terbuka';
  }

  @override
  String get achievementsUnlockedSemantics => 'Pencapaian terbuka';

  @override
  String get achievementsEmptyCategory =>
      'Belum ada pencapaian di kategori ini.';

  @override
  String get achievementsSecretSemantics => 'Pencapaian rahasia';

  @override
  String get achievementsSecretTitle => 'Pencapaian Rahasia';

  @override
  String get achievementsSecretHint => 'Terus bermain untuk menemukannya.';

  @override
  String achievementsUnlockedAt(String time) {
    return 'Terbuka $time';
  }

  @override
  String get achievementsLocked => 'Terkunci';

  @override
  String achievementsProgress(int current, int target) {
    return 'Progres $current/$target';
  }

  @override
  String get progressSignInTitle => 'Pantau progresmu';

  @override
  String get progressSignInMessage =>
      'Masuk untuk dapat XP, naik level, dan membangun streak.';

  @override
  String get progressLevelBadge => 'Lv';

  @override
  String get progressMaxLevelReached => 'Level maksimum tercapai';

  @override
  String progressStreakDays(int days) {
    return '${days}h';
  }

  @override
  String get progressGamesPlayedLabel => 'Game Dimainkan';

  @override
  String get progressRecentXp => 'Aktivitas XP Terbaru';

  @override
  String get progressNoXp => 'Mainkan game untuk mulai mendapatkan XP.';

  @override
  String get progressXpEarned => 'XP diperoleh';

  @override
  String get leaderboardEmptyTitle => 'Belum ada peringkat';

  @override
  String get leaderboardEmptyMessage =>
      'Mainkan game untuk jadi yang pertama di papan!';

  @override
  String get leaderboardScopeGlobal => 'Global';

  @override
  String get leaderboardScopeWeekly => 'Mingguan';

  @override
  String get leaderboardScopeMonthly => 'Bulanan';

  @override
  String leaderboardSeasonEndsIn(String time) {
    return 'Musim berakhir dalam $time';
  }

  @override
  String leaderboardPodiumSemantics(int rank, String name, int score) {
    final intl.NumberFormat scoreNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String scoreString = scoreNumberFormat.format(score);

    return 'Peringkat $rank, $name, $scoreString XP';
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

    return 'Peringkat $rank, $name, $detail, $scoreString XP';
  }

  @override
  String get leaderboardPlayToRank => 'Mainkan game untuk masuk peringkat.';

  @override
  String get leaderboardSignInToRank => 'Masuk untuk melihat peringkatmu.';
}
