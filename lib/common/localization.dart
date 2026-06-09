import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [Locale('en'), Locale('id')];

  bool get _isId => locale.languageCode == 'id';

  String get appName => _isId ? 'Aplikasi Cerita' : 'Story App';

  String get login => _isId ? 'Masuk' : 'Login';
  String get register => _isId ? 'Daftar' : 'Register';
  String get email => 'Email';
  String get password => _isId ? 'Kata Sandi' : 'Password';
  String get name => _isId ? 'Nama' : 'Name';
  String get loginButton => _isId ? 'Masuk' : 'Sign In';
  String get registerButton => _isId ? 'Daftar' : 'Sign Up';
  String get dontHaveAccount =>
      _isId ? 'Belum punya akun? ' : "Don't have an account? ";
  String get alreadyHaveAccount =>
      _isId ? 'Sudah punya akun? ' : 'Already have an account? ';
  String get loginSuccess => _isId ? 'Berhasil masuk!' : 'Login successful!';
  String get registerSuccess => _isId
      ? 'Registrasi berhasil! Silakan masuk.'
      : 'Registration successful! Please login.';
  String get emailRequired => _isId ? 'Email wajib diisi' : 'Email is required';
  String get emailInvalid =>
      _isId ? 'Format email tidak valid' : 'Invalid email format';
  String get passwordRequired =>
      _isId ? 'Kata sandi wajib diisi' : 'Password is required';
  String get passwordTooShort => _isId
      ? 'Kata sandi minimal 8 karakter'
      : 'Password must be at least 8 characters';
  String get nameRequired => _isId ? 'Nama wajib diisi' : 'Name is required';
  String get welcomeBack =>
      _isId ? 'Selamat Datang\nKembali!' : 'Welcome\nBack!';
  String get createAccount => _isId ? 'Buat Akun\nBaru' : 'Create\nNew Account';
  String get loginSubtitle => _isId
      ? 'Masuk untuk melihat cerita terbaru'
      : 'Sign in to see latest stories';
  String get registerSubtitle => _isId
      ? 'Daftar untuk mulai berbagi cerita'
      : 'Register to start sharing stories';

  String get discoverPart1 => _isId ? 'Temukan ' : 'Discover Amazing\n';
  String get discoverHighlight => _isId ? 'Cerita' : 'Stories';
  String get discoverPart2 => _isId ? '\nMenarik 📖' : ' 📖';
  String get discoverSubtitle =>
      _isId ? 'cerita terbaru untukmu' : 'latest stories for you';
  String get stories => _isId ? 'Cerita' : 'Stories';
  String get storyDetail => _isId ? 'Detail Cerita' : 'Story Detail';
  String get addStory => _isId ? 'Tambah Cerita' : 'Add Story';
  String get uploadStory => _isId ? 'Unggah Cerita' : 'Upload Story';
  String get description => _isId ? 'Deskripsi' : 'Description';
  String get descriptionHint => _isId
      ? 'Ceritakan momen menarikmu...'
      : 'Tell your interesting moment...';
  String get descriptionRequired =>
      _isId ? 'Deskripsi wajib diisi' : 'Description is required';
  String get camera => _isId ? 'Kamera' : 'Camera';
  String get gallery => _isId ? 'Galeri' : 'Gallery';
  String get upload => _isId ? 'Unggah' : 'Upload';
  String get uploadSuccess =>
      _isId ? 'Cerita berhasil diunggah!' : 'Story uploaded successfully!';
  String get noStories => _isId ? 'Belum ada cerita' : 'No stories yet';
  String get noStoriesSubtitle => _isId
      ? 'Jadilah yang pertama berbagi cerita!'
      : 'Be the first to share a story!';
  String get selectImage => _isId ? 'Pilih gambar' : 'Select an image';
  String get selectImageSubtitle => _isId
      ? 'Ambil foto dari kamera atau galeri'
      : 'Take a photo from camera or gallery';
  String get postedBy => _isId ? 'Diunggah oleh' : 'Posted by';

  String get logout => _isId ? 'Keluar' : 'Logout';
  String get logoutConfirm => _isId
      ? 'Apakah Anda yakin ingin keluar?'
      : 'Are you sure you want to logout?';
  String get cancel => _isId ? 'Batal' : 'Cancel';
  String get yes => _isId ? 'Ya' : 'Yes';
  String get error => _isId ? 'Terjadi kesalahan' : 'Something went wrong';
  String get retry => _isId ? 'Coba Lagi' : 'Retry';
  String get noData => _isId ? 'Tidak ada data' : 'No data';
  String get language => _isId ? 'Bahasa' : 'Language';
  String get darkMode => _isId ? 'Mode Gelap' : 'Dark Mode';
  String get networkError =>
      _isId ? 'Tidak ada koneksi internet' : 'No internet connection';
  String get serverError =>
      _isId ? 'Terjadi kesalahan pada server' : 'Server error occurred';

  String get pickLocation => _isId ? 'Pilih Lokasi' : 'Pick Location';
  String get confirm => _isId ? 'Konfirmasi' : 'Confirm';
  String get selectedLocation => _isId ? 'Lokasi Dipilih' : 'Selected Location';
  String get location => _isId ? 'Lokasi' : 'Location';
  String get addLocation => _isId ? 'Tambah Lokasi' : 'Add Location';
  String get removeLocation => _isId ? 'Hapus Lokasi' : 'Remove Location';
  String get locationLabel => _isId ? 'Lokasi Cerita' : 'Story Location';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'id'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
