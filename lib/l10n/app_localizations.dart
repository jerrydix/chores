import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

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
    Locale('ru')
  ];

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @notEnable.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notEnable;

  /// No description provided for @notInterval.
  ///
  /// In en, this message translates to:
  /// **'Notification Interval'**
  String get notInterval;

  /// No description provided for @sys.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get sys;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Once a week (Monday)'**
  String get monday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Once a week (Saturday)'**
  String get sunday;

  /// No description provided for @twice.
  ///
  /// In en, this message translates to:
  /// **'Twice a week'**
  String get twice;

  /// No description provided for @every.
  ///
  /// In en, this message translates to:
  /// **'Every day (lmao)'**
  String get every;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Once a week (Wednesday)'**
  String get friday;

  /// No description provided for @en.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get en;

  /// No description provided for @de.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get de;

  /// No description provided for @ru.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get ru;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get or;

  /// No description provided for @leave_wg.
  ///
  /// In en, this message translates to:
  /// **'Leave shared apartment'**
  String get leave_wg;

  /// No description provided for @leave_wg_t.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave the shared apartment?'**
  String get leave_wg_t;

  /// No description provided for @wg_settings.
  ///
  /// In en, this message translates to:
  /// **'Shared apartment options'**
  String get wg_settings;

  /// No description provided for @select_wg.
  ///
  /// In en, this message translates to:
  /// **'Select shared apartment'**
  String get select_wg;

  /// No description provided for @forgot_pw.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgot_pw;

  /// No description provided for @reset_pw.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get reset_pw;

  /// No description provided for @reset_pw_t.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address to receive a password reset link.'**
  String get reset_pw_t;

  /// No description provided for @reset_pw_b.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get reset_pw_b;

  /// No description provided for @new_wg.
  ///
  /// In en, this message translates to:
  /// **'Create new shared apartment'**
  String get new_wg;

  /// No description provided for @wg_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get wg_name;

  /// No description provided for @wg_use_template.
  ///
  /// In en, this message translates to:
  /// **'Use chores template'**
  String get wg_use_template;

  /// No description provided for @wg_exists.
  ///
  /// In en, this message translates to:
  /// **'This name is already taken. Please choose another one.'**
  String get wg_exists;

  /// No description provided for @garbage.
  ///
  /// In en, this message translates to:
  /// **'Garbage Master'**
  String get garbage;

  /// No description provided for @g100plastic.
  ///
  /// In en, this message translates to:
  /// **'Plastic waste'**
  String get g100plastic;

  /// No description provided for @g101residual.
  ///
  /// In en, this message translates to:
  /// **'Residual waste'**
  String get g101residual;

  /// No description provided for @g102organic.
  ///
  /// In en, this message translates to:
  /// **'Organic waste'**
  String get g102organic;

  /// No description provided for @g103paper.
  ///
  /// In en, this message translates to:
  /// **'Paper waste'**
  String get g103paper;

  /// No description provided for @g104glass.
  ///
  /// In en, this message translates to:
  /// **'Glass waste'**
  String get g104glass;

  /// No description provided for @g105bottles.
  ///
  /// In en, this message translates to:
  /// **'Return bottles'**
  String get g105bottles;

  /// No description provided for @bathroom.
  ///
  /// In en, this message translates to:
  /// **'Bathroom Master'**
  String get bathroom;

  /// No description provided for @b206mirrors.
  ///
  /// In en, this message translates to:
  /// **'Clean mirrors'**
  String get b206mirrors;

  /// No description provided for @b207sink.
  ///
  /// In en, this message translates to:
  /// **'Clean sink'**
  String get b207sink;

  /// No description provided for @b208bath.
  ///
  /// In en, this message translates to:
  /// **'Clean bath'**
  String get b208bath;

  /// No description provided for @b209toilet.
  ///
  /// In en, this message translates to:
  /// **'Clean toilet'**
  String get b209toilet;

  /// No description provided for @b210dust.
  ///
  /// In en, this message translates to:
  /// **'Wipe dust on shelf and surfaces'**
  String get b210dust;

  /// No description provided for @b211carpet.
  ///
  /// In en, this message translates to:
  /// **'Change carpet'**
  String get b211carpet;

  /// No description provided for @b212towel.
  ///
  /// In en, this message translates to:
  /// **'Change towel'**
  String get b212towel;

  /// No description provided for @b213b_waste.
  ///
  /// In en, this message translates to:
  /// **'Take out bathroom waste'**
  String get b213b_waste;

  /// No description provided for @kitchen.
  ///
  /// In en, this message translates to:
  /// **'Kitchen Chef'**
  String get kitchen;

  /// No description provided for @b314surfaces.
  ///
  /// In en, this message translates to:
  /// **'Clean (glass) surfaces, including table'**
  String get b314surfaces;

  /// No description provided for @b315stove.
  ///
  /// In en, this message translates to:
  /// **'Clean stove and oven'**
  String get b315stove;

  /// No description provided for @b316fridge.
  ///
  /// In en, this message translates to:
  /// **'Empty and clean fridge'**
  String get b316fridge;

  /// No description provided for @b317cloths.
  ///
  /// In en, this message translates to:
  /// **'Wash cloths, towel and carpet'**
  String get b317cloths;

  /// No description provided for @vacuum.
  ///
  /// In en, this message translates to:
  /// **'Vacuumator'**
  String get vacuum;

  /// No description provided for @b418v_kitchen.
  ///
  /// In en, this message translates to:
  /// **'Vacuum kitchen'**
  String get b418v_kitchen;

  /// No description provided for @b419v_bath.
  ///
  /// In en, this message translates to:
  /// **'Vacuum bathroom'**
  String get b419v_bath;

  /// No description provided for @b420v_living.
  ///
  /// In en, this message translates to:
  /// **'Vacuum living room'**
  String get b420v_living;

  /// No description provided for @b421v_stairs.
  ///
  /// In en, this message translates to:
  /// **'Vacuum stairs'**
  String get b421v_stairs;

  /// No description provided for @b422v_corridor.
  ///
  /// In en, this message translates to:
  /// **'Vacuum corridor'**
  String get b422v_corridor;

  /// No description provided for @b423wipe.
  ///
  /// In en, this message translates to:
  /// **'Wipe floor'**
  String get b423wipe;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logout_t.
  ///
  /// In en, this message translates to:
  /// **'Logout from Chores?'**
  String get logout_t;

  /// No description provided for @cw.
  ///
  /// In en, this message translates to:
  /// **'CW'**
  String get cw;

  /// No description provided for @n_title.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get n_title;

  /// No description provided for @n_text.
  ///
  /// In en, this message translates to:
  /// **'to finish your chores for the week.'**
  String get n_text;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active status'**
  String get active;

  /// No description provided for @noPrimaryRoles.
  ///
  /// In en, this message translates to:
  /// **'Your status is set inactive.'**
  String get noPrimaryRoles;

  /// No description provided for @noPrimaryRoles2.
  ///
  /// In en, this message translates to:
  /// **'No chores are assigned to you.'**
  String get noPrimaryRoles2;

  /// No description provided for @uname.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get uname;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @pw.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get pw;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login to Chores'**
  String get login;

  /// No description provided for @login_b.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login_b;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign up to Chores'**
  String get signup;

  /// No description provided for @signup_b.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signup_b;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccount;

  /// No description provided for @finAllTasks.
  ///
  /// In en, this message translates to:
  /// **'Finished all tasks'**
  String get finAllTasks;
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
      <String>['de', 'en', 'ru'].contains(locale.languageCode);

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
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
