// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Settings';

  @override
  String get dashboard => 'Tasks';

  @override
  String get overview => 'Overview';

  @override
  String get about => 'About';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get notEnable => 'Notifications';

  @override
  String get notInterval => 'Notification schedule';

  @override
  String get sys => 'System';

  @override
  String get dark => 'Dark';

  @override
  String get light => 'Light';

  @override
  String get monday => 'Once a week (Monday)';

  @override
  String get sunday => 'Once a week (Saturday)';

  @override
  String get twice => 'Twice a week';

  @override
  String get every => 'Every day (lmao)';

  @override
  String get info => 'Info';

  @override
  String get options => 'Options';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get friday => 'Once a week (Wednesday)';

  @override
  String get en => 'English';

  @override
  String get de => 'Deutsch';

  @override
  String get ru => 'Русский';

  @override
  String get el => 'Ελληνικά';

  @override
  String get zh => '中文（简体）';

  @override
  String get or => 'Or continue with';

  @override
  String get leave_wg => 'Leave shared apartment';

  @override
  String get leave_wg_t =>
      'Are you sure you want to leave the shared apartment?';

  @override
  String get wg_settings => 'Shared apartment options';

  @override
  String get select_wg => 'Select shared apartment';

  @override
  String get forgot_pw => 'Forgot password?';

  @override
  String get reset_pw => 'Reset password';

  @override
  String get reset_pw_t =>
      'Enter your email address and receive a link to reset your password.';

  @override
  String get reset_pw_b => 'Send reset link';

  @override
  String get new_wg => 'Create new shared apartment';

  @override
  String get wg_name => 'Name';

  @override
  String get wg_use_template => 'Use chores template';

  @override
  String get wg_exists =>
      'This name is already taken. Please choose another one.';

  @override
  String get wg_full => 'This WG is full, you cannot join.';

  @override
  String get wg_gone => 'This WG no longer exists.';

  @override
  String get garbage => 'Garbage Master';

  @override
  String get g100plastic => 'Plastic waste';

  @override
  String get g101residual => 'Residual waste';

  @override
  String get g102organic => 'Organic waste';

  @override
  String get g103paper => 'Paper waste';

  @override
  String get g104glass => 'Glass waste';

  @override
  String get g105bottles => 'Return bottles';

  @override
  String get bathroom => 'Bathroom Master';

  @override
  String get b206mirrors => 'Clean mirrors';

  @override
  String get b207sink => 'Clean sink';

  @override
  String get b208bath => 'Clean bath';

  @override
  String get b209toilet => 'Clean toilet';

  @override
  String get b210dust => 'Wipe dust on shelf and surfaces';

  @override
  String get b211carpet => 'Change carpet';

  @override
  String get b212towel => 'Change towel';

  @override
  String get b213b_waste => 'Take out bathroom waste';

  @override
  String get kitchen => 'Kitchen Chef';

  @override
  String get b314surfaces => 'Clean (glass) surfaces, including table';

  @override
  String get b315stove => 'Clean stove and oven';

  @override
  String get b316fridge => 'Empty and clean fridge';

  @override
  String get b317cloths => 'Wash cloths, towel and carpet';

  @override
  String get vacuum => 'Vacuumator';

  @override
  String get b418v_kitchen => 'Vacuum kitchen';

  @override
  String get b419v_bath => 'Vacuum bathroom';

  @override
  String get b420v_living => 'Vacuum living room';

  @override
  String get b421v_stairs => 'Vacuum stairs';

  @override
  String get b422v_corridor => 'Vacuum corridor';

  @override
  String get b423wipe => 'Wipe floor';

  @override
  String get logout => 'Logout';

  @override
  String get logout_t => 'Logout from Chores?';

  @override
  String get cw => 'CW';

  @override
  String get n_title => 'Reminder';

  @override
  String get n_text => 'to finish your chores for the week.';

  @override
  String get active => 'Available to work';

  @override
  String get noPrimaryRoles => 'You are not available to work.';

  @override
  String get noPrimaryRoles2 => 'No chores are assigned to you.';

  @override
  String get uname => 'Username';

  @override
  String get email => 'Email';

  @override
  String get pw => 'Password';

  @override
  String get login => 'Login to Chores';

  @override
  String get login_b => 'Login';

  @override
  String get signup => 'Sign up to Chores';

  @override
  String get signup_b => 'Sign up';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get finAllTasks => 'Finished all tasks';

  @override
  String get role_task_settings => 'Role and Task Settings';

  @override
  String get algo_settings => 'Role Assignment';

  @override
  String get algo_rotating => 'Weekly rotation';

  @override
  String get algo_rotating_desc =>
      'Roles rotate each week so everyone takes turns';

  @override
  String get algo_fixed => 'Always static';

  @override
  String get algo_fixed_desc =>
      'Same roles assigned to the same people every week';

  @override
  String get algo_random => 'Random (fair)';

  @override
  String get algo_random_desc =>
      'Randomly shuffled each week, balanced over time';

  @override
  String get no_tasks_yet => 'No tasks yet';

  @override
  String get add_tasks_hint => 'Add roles & chores in Settings';

  @override
  String get no_roles_yet => 'No roles yet';

  @override
  String get add_roles_hint => 'Tap + to add a role or chore';

  @override
  String get add_role => 'Add Role';

  @override
  String get add_chore => 'Add Chore';

  @override
  String add_chore_to(String role) {
    return 'Add Chore to $role';
  }

  @override
  String get role_name => 'Role Name';

  @override
  String get chore_name => 'Chore Name';

  @override
  String get add => 'Add';

  @override
  String get delete => 'Delete';

  @override
  String get delete_role => 'Delete Role';

  @override
  String delete_role_t(String role) {
    return 'Delete \"$role\"?';
  }

  @override
  String get delete_role_desc =>
      'This will also delete all chores in this role.';

  @override
  String get delete_role_empty => 'This role has no chores.';

  @override
  String get no_chores_for_role => 'No chores for this role';

  @override
  String get pick_role_icon => 'Pick Role Icon';

  @override
  String get pick_icon => 'Pick an icon';

  @override
  String get select_role => 'Select Role';

  @override
  String get role_exists => 'A role with this name already exists.';

  @override
  String get chore_exists => 'This chore already exists in this role.';

  @override
  String get edit_role => 'Edit Role';

  @override
  String get edit_chore => 'Edit Chore';

  @override
  String get save => 'Save';
}
