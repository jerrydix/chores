import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chores/widgets/navigationbar.dart';
import 'package:flutter/material.dart';
import 'package:chores/main.dart';

class NotificationService {
  static Future<void> initializeNotifications() async {
    await AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(channelGroupKey: "reminder_channel_group", channelKey: "reminder_channel", channelName: "reminder_channel", channelDescription: "Reminder channel", defaultColor: Colors.white, ledColor: Colors.white, importance: NotificationImportance.Max, channelShowBadge: true, onlyAlertOnce: true, playSound: true, criticalAlerts: true)
        ],
        channelGroups:  [
          NotificationChannelGroup(channelGroupKey: "reminder_channel_group", channelGroupName: "Reminder group")
        ],
        debug: true
    );

    await AwesomeNotifications().isNotificationAllowed().then(
        (allowed) async {
          if (!allowed) {
            await AwesomeNotifications().requestPermissionToSendNotifications();
          }
        }
    );

    AwesomeNotifications().setListeners(
        onActionReceivedMethod:         onActionReceivedMethod,
        onNotificationCreatedMethod:    onNotificationCreatedMethod,
        onNotificationDisplayedMethod:  onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:  onDismissActionReceivedMethod
    );
  }

  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future <void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    debugPrint("notification created");
    final payload = receivedNotification.payload ?? {};
    if (payload["navigate"] == "true") {
      MyApp.navigatorKey.currentState?.push(
        MaterialPageRoute(
            builder: (_) => const NavBar(),
        )
      );
    }
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future <void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    debugPrint("notification displayed");
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future <void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    debugPrint("notification dismissed action");
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future <void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    debugPrint("notification action");

    // Navigate into pages, avoiding to open the notification details page over another details page already opened
    MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil('/notification-page',
            (route) => (route.settings.name != '/notification-page') || route.isFirst,
        arguments: receivedAction);
  }

  static Future<void> showNotification({
    required final String title,
    required final String body,
    final String? summary,
    final Map<String, String>? payload,
    final ActionType actionType = ActionType.Default,
    final NotificationLayout notificationLayout = NotificationLayout.Default,
    final NotificationCategory? category,
    final String? bigPicture,
    final List<NotificationActionButton>? actionButtons,
    final bool scheduled = false,
    final int? interval,
  }) async {
    assert(!scheduled || (scheduled && interval != null));
    
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: -1,
          channelKey: "reminder_channel",
          title: title,
          body: body,
          actionType: actionType,
          notificationLayout: notificationLayout,
          summary: summary,
          category: category,
          payload: payload,
          bigPicture: bigPicture,
        ),
      actionButtons: actionButtons,
      schedule: scheduled ? NotificationInterval(
        interval: interval,
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        preciseAlarm: true,
      ) : null,
    );
  }
}