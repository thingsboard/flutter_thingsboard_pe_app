package org.thingsboard.pe.app

import android.content.Intent
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService

/**
 * Suppresses the FCM SDK's automatic tray notification for messages that
 * carry a notification payload, so they can be rendered on the Dart side via
 * flutter_local_notifications with the icon configured in the notification
 * template (PROD-7932).
 *
 * Delivery to Dart is not affected: FlutterFirebaseMessagingReceiver gets its
 * own copy of the original broadcast and forwards the complete message to
 * onMessage/onBackgroundMessage in every app state. Without stripping, the
 * base FirebaseMessagingService.handleIntent() would post the notification
 * itself (icon-less) whenever the app is not in the foreground.
 */
class TbFirebaseMessagingService : FlutterFirebaseMessagingService() {

    override fun handleIntent(intent: Intent) {
        if (intent.action == ACTION_MESSAGE_RECEIVE) {
            stripNotificationPayload(intent)
        }
        super.handleIntent(intent)
    }

    private fun stripNotificationPayload(intent: Intent) {
        val keys = intent.extras?.keySet() ?: return
        keys
            .filter {
                it.startsWith(NOTIFICATION_KEY_PREFIX) ||
                    it.startsWith(NOTIFICATION_KEY_PREFIX_OLD)
            }
            .forEach { intent.removeExtra(it) }
    }

    private companion object {
        const val ACTION_MESSAGE_RECEIVE = "com.google.android.c2dm.intent.RECEIVE"
        const val NOTIFICATION_KEY_PREFIX = "gcm.n."
        const val NOTIFICATION_KEY_PREFIX_OLD = "gcm.notification."
    }
}
