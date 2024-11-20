importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-messaging.js');

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

firebase.initializeApp(firebaseConfig);

const messaging = firebase.messaging();
