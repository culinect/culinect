// src/services/post-service.js
import { sendNotification } from './notification-service';  // Import the sendNotification function
import { templates } from '../templates/message-templates';  // Import your templates

// Function to handle the creation of a post
async function createPost(postData) {
  // After post creation logic (e.g., saving the post to the database)

  // Example user token (you should get this from the user's device data or database)
  const userToken = 'user-device-token';

  // Example data that will be sent in the notification
  const notificationData = {
    id: postData.postId,
    userName: postData.userName,
    title: postData.title,
    webUrl: `https://culinect.com/posts/${postData.postId}`  // The URL for clicking the notification
  };

  // Use the post template for notification
  const template = templates.post;

  // Send the notification
  const isSent = await sendNotification(userToken, notificationData, template);

  if (isSent) {
    console.log('Notification successfully sent!');
  } else {
    console.log('Failed to send notification.');
  }
}

export { createPost };  // Export the function
