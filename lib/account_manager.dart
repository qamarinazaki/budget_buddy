import 'app_data_manager.dart';

class UserAccount {
  final String name;
  final String email;
  final String phone;
  final String course;
  final String studyYear;

  UserAccount({
    required this.name,
    required this.email,
    required this.phone,
    required this.course,
    required this.studyYear,
  });
}

class AccountManager {

  static final List<UserAccount> _accounts = [];

  static int _currentIndex = 0;

  static UserAccount? get currentAccount {

    if (_accounts.isNotEmpty) {
      return _accounts[_currentIndex];
    }

    if (AppDataManager.userEmail.isNotEmpty) {
      return UserAccount(
        name: AppDataManager.userName,
        email: AppDataManager.userEmail,
        phone: AppDataManager.userPhone,
        course: AppDataManager.course,
        studyYear: AppDataManager.studyYear,
      );
    }

    return null;
  }

  static List<UserAccount> get allAccounts {

    if (_accounts.isNotEmpty) {
      return _accounts;
    }

    if (AppDataManager.userEmail.isNotEmpty) {
      return [
        UserAccount(
          name: AppDataManager.userName,
          email: AppDataManager.userEmail,
          phone: AppDataManager.userPhone,
          course: AppDataManager.course,
          studyYear: AppDataManager.studyYear,
        ),
      ];
    }

    return [];
  }

  static void addAccount(
      UserAccount account,
      ) {

    _accounts.add(account);

    _currentIndex = _accounts.length - 1;
  }

  static Future<void> switchAccount(
      int index,
      ) async {

    if (index >= 0 &&
        index < _accounts.length) {

      _currentIndex = index;

      AppDataManager.userName =
          _accounts[index].name;

      AppDataManager.userEmail =
          _accounts[index].email;

      AppDataManager.userPhone =
          _accounts[index].phone;

      AppDataManager.course =
          _accounts[index].course;

      AppDataManager.studyYear =
          _accounts[index].studyYear;
    }
  }

  static Future<void> signOutThisAccount() async {

    if (_accounts.isNotEmpty) {

      _accounts.removeAt(_currentIndex);

      if (_accounts.isNotEmpty) {

        _currentIndex = 0;

        AppDataManager.userName =
            _accounts[0].name;

        AppDataManager.userEmail =
            _accounts[0].email;

        AppDataManager.userPhone =
            _accounts[0].phone;

        AppDataManager.course =
            _accounts[0].course;

        AppDataManager.studyYear =
            _accounts[0].studyYear;

      } else {

        AppDataManager.userName = "";
        AppDataManager.userEmail = "";
        AppDataManager.userPhone = "";
        AppDataManager.course = "";
        AppDataManager.studyYear = "";
      }
    }
  }

  static Future<void> signOutAllAccounts() async {

    _accounts.clear();

    AppDataManager.resetAllData();
  }
}