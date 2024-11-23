// src/services/notification-service.js
import { config } from '../config/notification-config';  // Import the config (you've already set it)
import { createNotificationPayload } from '../utils/notification-utils';  // Import the utility function for payload creation

// Send the notification to FCM
async function sendNotification(userToken, data, template) {
  try {
    // Generate the notification payload using the template
    const payload = createNotificationPayload(userToken, data, template);

    // Send the notification via Firebase Cloud Messaging
    const response = await fetch(config.firebase.apiEndpoint, {
      method: "POST",
      headers: {
        "Authorization": `key=${process.env.FIREBASE_SERVER_KEY}`,  // Add your Firebase server key here
        "Content-Type": "application/json"
      },
      body: JSON.stringify(payload)
    });

    // Parse the response
    const responseBody = await response.json();
    if (!response.ok) {
      console.error('FCM Error:', responseBody);
      return false;  // Return false if the notification failed
    }

    console.log('Notification sent successfully:', responseBody);
    return true;  // Return true if the notification was successful
  } catch (error) {
    // Catch and log any errors during the fetch request
    console.error('Error sending notification:', error);
    return false;  // Return false if there was an error
  }
}

export { sendNotification };  // Export the function for use in other parts of your app
