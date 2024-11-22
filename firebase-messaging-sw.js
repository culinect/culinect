importScripts("https://www.gstatic.com/firebasejs/9.x.x/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/9.x.x/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "your-api-key",
  authDomain: "your-auth-domain",
  projectId: "your-project-id",
  storageBucket: "your-storage-bucket",
  messagingSenderId: "your-sender-id",
  appId: "your-app-id"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('Received background message:', payload);

  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/icon-192x192.png'
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});
