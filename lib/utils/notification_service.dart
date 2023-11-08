import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chores/widgets/navigationbar.dart';
import 'package:flutter/material.dart';
import 'package:chores/main.dart';

class NotificationService {
  static Future<void> initializeNotifications() async {
    await AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(
              channelGroupKey: "reminder_channel_group",
              channelKey: "reminder_channel",
              channelName: "reminder_channel",
              channelDescription: "Reminder channel",
              defaultColor: Colors.transparent,
              ledColor: Colors.white,
              importance: NotificationImportance.Max,
              defaultPrivacy: NotificationPrivacy.Public,
              defaultRingtoneType: DefaultRingtoneType.Notification,
              locked: true,
              enableVibration: true,
              playSound: true,
              criticalAlerts: true)
        ],
        channelGroups: [
          NotificationChannelGroup(
              channelGroupKey: "reminder_channel_group",
              channelGroupName: "Reminder group")
        ],
        debug: true);

    await AwesomeNotifications().isNotificationAllowed().then((allowed) async {
      if (!allowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    AwesomeNotifications().setListeners(
        onActionReceivedMethod: onActionReceivedMethod,
        onNotificationCreatedMethod: onNotificationCreatedMethod,
        onNotificationDisplayedMethod: onNotificationDisplayedMethod,
        onDismissActionReceivedMethod: onDismissActionReceivedMethod);
  }

  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint("notification created");
    final payload = receivedNotification.payload ?? {};
    if (payload["navigate"] == "true") {
      MyApp.navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (_) => const NavBar(),
      ));
    }
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint("notification displayed");
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint("notification dismissed action");
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint("notification action");

    // Navigate into pages, avoiding to open the notification details page over another details page already opened
    MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/notification-page',
        (route) =>
            (route.settings.name != '/notification-page') || route.isFirst,
        arguments: receivedAction);
  }

  static Future<void> scheduleChoresNotification({
    required final int id,
    required final String title,
    required final String body,
    required final int weekday,
    final List<NotificationActionButton>? actionButtons,
  }) async {
    Random random = Random();
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: random.nextInt(10000),
        channelKey: "reminder_channel",
        title: title,
        body: body,
        category: NotificationCategory.Reminder,
        actionType: ActionType.Default,
        notificationLayout: NotificationLayout.BigText,
        locked: true,
        wakeUpScreen: true,
        fullScreenIntent: true,
        backgroundColor: Colors.transparent,
      ),
      actionButtons: actionButtons,
      schedule: NotificationCalendar(
        minute: 00,
        hour: 12,
        weekday: weekday,
        preciseAlarm: false,
        allowWhileIdle: true,
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        repeats: true,
      ),
    );
  }
}
