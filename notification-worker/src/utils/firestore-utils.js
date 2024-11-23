export const firestoreUtils = {
    storeNotification: async (notification) => {
        const docRef = await firebase.firestore()
            .collection('notifications')
            .add({
                ...notification,
                isRead: false,
                createdAt: firebase.firestore.FieldValue.serverTimestamp()
            });
        return docRef.id;
    },

    getNotifications: async (userId, page = 1, limit = 20) => {
        const notifications = await firebase.firestore()
            .collection('notifications')
            .where('userId', '==', userId)
            .orderBy('createdAt', 'desc')
            .limit(limit)
            .offset((page - 1) * limit)
            .get();

        return notifications.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        }));
    },

    markAsRead: async (notificationIds) => {
        const batch = firebase.firestore().batch();
        notificationIds.forEach(id => {
            const ref = firebase.firestore().collection('notifications').doc(id);
            batch.update(ref, { isRead: true });
        });
        return batch.commit();
    },

    getUnreadCount: async (userId) => {
        const snapshot = await firebase.firestore()
            .collection('notifications')
            .where('userId', '==', userId)
            .where('isRead', '==', false)
            .count()
            .get();
        return snapshot.data().count;
    },

    // New function to fetch user document and fcmTokens
    getUserDoc: async (userId) => {
        try {
            const userDoc = await firebase.firestore()
                .collection('users')
                .doc(userId)
                .get();

            if (!userDoc.exists) {
                console.error(`User not found: ${userId}`);
                return null;
            }

            const userData = userDoc.data();
            return userData; // Return user data containing fcmTokens
        } catch (error) {
            console.error("Error fetching user document:", error);
            return null;
        }
    }
};
