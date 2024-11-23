import { config } from '../config/notification-config';

export const createNotificationPayload = (userToken, data, template) => {
  const createNotificationPayload = (userToken, data, template) => {
    const baseNotification = {
      title: template.title,
      body: template.body(data)
    };
    return {
      to: userToken,
      notification: baseNotification,
      data: {
        type: template.type,
        entityId: data.id,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        ...data
      },
      android: {
        priority: "high",
        notification: {
          channel_id: "default"
        }
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1
          }
        }
      },
      webpush: {
        notification: {
          ...baseNotification,
          icon: config.defaultIcons.web,
          badge: config.defaultIcons.badge,
          vibrate: [100, 50, 100],
          requireInteraction: true
        },
        fcm_options: {
          link: data.webUrl
        }
      }
    };
  };
  }
