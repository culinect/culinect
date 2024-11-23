const webPushConfig = {
  vapidKey: 'BHHCPv2z55ld-VqQ4M3BeU67jNolT5hv_ddEmD7abow_vofBsDrAVblppZmzf-AAPj5dNXGNhqFX0JSGuUkLSNI',
  notificationDefaults: {
    icon: '/assets/icons/icon-192x192.png',
    badge: '/assets/icons/badge-72x72.png',
    vibrate: [100, 50, 100]
  }
};

// Send a notification to the user's browser using the VAPID key
async function sendPushNotification(subscription, payload) {
  const { vapidKey, notificationDefaults } = webPushConfig;

  const response = await fetch('https://fcm.googleapis.com/fcm/send', {
    method: 'POST',
    headers: {
      'Authorization': `key=YOUR_SERVER_KEY`, // FCM Server Key
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      to: subscription.endpoint, // The endpoint received from the client subscription
      notification: {
        title: payload.title,
        body: payload.body,
        icon: notificationDefaults.icon,
        badge: notificationDefaults.badge,
        vibrate: notificationDefaults.vibrate,
      },
      data: payload.data, // Additional data to send along with the notification
      ttl: 3600 // Time to live in seconds
    })
  });

  if (!response.ok) {
    throw new Error('Failed to send push notification');
  }

  return response.json(); // Return the result
}

// Handle incoming requests to the Worker
async function handleRequest(request) {
  const { method, headers } = request;

  if (method === 'POST') {
    try {
      const data = await request.json();
      const { subscription, payload } = data;

      // Send the push notification
      const result = await sendPushNotification(subscription, payload);

      return new Response(JSON.stringify(result), { status: 200 });
    } catch (error) {
      return new Response(`Error sending notification: ${error.message}`, { status: 500 });
    }
  }

  return new Response('Invalid method', { status: 405 });
}

addEventListener('fetch', (event) => {
  event.respondWith(handleRequest(event.request));
});
