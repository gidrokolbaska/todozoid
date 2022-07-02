part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const login = _Paths.login;
  static const home = _Paths.home;
  static const tasksDiary = _Paths.tasksDiary;
}

abstract class _Paths {
  static const login = '/login';
  static const home = '/home';
  static const tasksDiary = '/tasksDiary';
}
