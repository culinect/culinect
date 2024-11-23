// Import Firebase SDK
import { initializeApp } from 'https://www.gstatic.com/firebasejs/9.x.x/firebase-app.js';
import { getFirestore } from 'https://www.gstatic.com/firebasejs/9.x.x/firebase-firestore.js';
import { getMessaging } from 'https://www.gstatic.com/firebasejs/9.x.x/firebase-messaging.js';


import { templates } from './templates/message-templates';
import { config } from './config/notification-config';
import { createNotificationPayload } from './utils/notification-utils';
import { firestoreUtils } from './utils/firestore-utils';

const FIREBASE_SERVER_KEY = globalThis.FIREBASE_SERVER_KEY;
const VAPID_PUBLIC_KEY = globalThis.VAPID_PUBLIC_KEY;
const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*", // Adjust this as necessary
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization"
};
const firebaseConfig = {
		apiKey: 'AIzaSyBXbbSsDVH1eVE297nCyU9euFilYmJWH1U',
      appId: '1:553932496521:web:bec35d05cb23cd9beef058',
      messagingSenderId: '553932496521',
      projectId: 'culinect-social',
      authDomain: 'culinect-social.firebaseapp.com',
      databaseURL: 'https://culinect-social-default-rtdb.firebaseio.com',
      storageBucket: 'culinect-social.appspot.com',
      measurementId: 'G-RQ20V98BR9',
};
// Initialize Firebase
firebase.initializeApp(firebaseConfig);

// Access Firebase services
const firestore = firebase.firestore();
const messaging = firebase.messaging();

async function handleRequest(request) {
  try {
    if (request.method === "OPTIONS") {
      return new Response(null, {
        status: 204,
        headers: CORS_HEADERS
      });
    }

    if (request.method !== "POST") {
      return createErrorResponse(405, "Method not allowed");
    }
    console.log("VAPID_PUBLIC_KEY:", { VAPID_PUBLIC_KEY });
    console.log("FIREBASE_SERVER_KEY:", { FIREBASE_SERVER_KEY });

    const { type, data } = await request.json();
    console.log("Request Received:", { type, data });

    // Validate request data
    if (!data || !data.userId || !type || !data.content) {
      return createErrorResponse(400, "Missing required fields (userId, type, content)");
    }

    // Fetch template for the notification type
    const notificationType = type.toLowerCase();
    const template = templates[notificationType];
    if (!template) {
      return createErrorResponse(400, `Invalid notification type: ${type}`);
    }

    console.log("Template Found:", template);

    // Fetch user tokens
    const userTokens = await fetchUserTokens(data.userId);
    if (!userTokens?.length) {
      return createErrorResponse(404, `No FCM tokens found for userId: ${data.userId}`);
    }

    console.log("User Tokens:", userTokens);

    // Send notifications
    const results = await Promise.all(
      userTokens.map((token) =>
        sendNotification(token, createNotificationPayload(token, data, template))
      )
    );

    console.log("Notification Results:", results);

    // Store notification document
    const notificationDoc = {
      userId: data.userId,
      type: notificationType,
      title: template.title,
      body: template.body,
      data,
      isRead: false,
      entityId: data.id,
      entityType: notificationType,
      timestamp: new Date().toISOString()
    };
    await storeNotification(notificationDoc);

    return new Response(
      JSON.stringify({ success: true, results }),
      {
        status: 200,
        headers: { "Content-Type": "application/json", ...CORS_HEADERS }
      }
    );
  } catch (error) {
    console.error("Error occurred:", error);
    return createErrorResponse(500, "Internal server error");
  }
}

async function fetchUserTokens(userId) {
  try {
    // Call the getUserDoc function from firestoreUtils to fetch user data
    const userData = await firestoreUtils.getUserDoc(userId);
    if (!userData || !userData.fcmTokens) {
      console.error(`No fcmTokens found for userId: ${userId}`);
      return [];
    }

    // Extract fcmTokens and filter out any invalid tokens
    const fcmTokens = userData.fcmTokens || [];
    return fcmTokens.filter((token) => token); // Filter out empty/null tokens
  } catch (error) {
    console.error("Error fetching user tokens:", error);
    return [];
  }
}


async function sendNotification(token, payload) {
  const notificationPayload = {
    to: token,
    notification: {
      title: payload.title,
      body: payload.body,
      icon: payload.icon || "/assets/icons/icon-192x192.png",
      badge: payload.badge || "/assets/icons/badge-72x72.png",
      vibrate: payload.vibrate || [100, 50, 100]
    },
    data: payload.data,
    ttl: 3600,
    priority: "high",
    vapidKeys: {
      publicKey: VAPID_PUBLIC_KEY
    }
  };

  try {
    const response = await fetch(config.firebase.apiEndpoint, {
      method: "POST",
      headers: {
        "Authorization": `key=${FIREBASE_SERVER_KEY}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify(notificationPayload)
    });

    if (!response.ok) {
      console.error(`Failed to send notification to token ${token}:`, response.statusText);
    }
    return response.ok;
  } catch (error) {
    console.error("Error sending notification:", error);
    return false;
  }
}

function createErrorResponse(status, message) {
  return new Response(
    JSON.stringify({ error: message }),
    {
      status,
      headers: { "Content-Type": "application/json", ...CORS_HEADERS }
    }
  );
}

addEventListener("fetch", (event) => {
  event.respondWith(handleRequest(event.request));
});
