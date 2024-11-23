importScripts('https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.23.0/firebase-messaging-compat.js');
firebase.initializeApp({
  apiKey: 'AIzaSyBXbbSsDVH1eVE297nCyU9euFilYmJWH1U',
  appId: '1:553932496521:web:bec35d05cb23cd9beef058',
  messagingSenderId: '553932496521',
  projectId: 'culinect-social',
  authDomain: 'culinect-social.firebaseapp.com',
  storageBucket: 'culinect-social.appspot.com',
  measurementId: 'G-RQ20V98BR9'
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log("onBackgroundMessage", payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png'
  };
  return self.registration.showNotification(notificationTitle, notificationOptions);
});
