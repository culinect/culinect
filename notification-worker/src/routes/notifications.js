export async function getNotifications(userId, page = 1, limit = 20) {
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
}

export async function markAsRead(notificationIds) {
    const batch = firebase.firestore().batch();

    notificationIds.forEach(id => {
        const ref = firebase.firestore().collection('notifications').doc(id);
        batch.update(ref, { isRead: true });
    });

    await batch.commit();
}

export async function getUnreadCount(userId) {
    const snapshot = await firebase.firestore()
        .collection('notifications')
        .where('userId', '==', userId)
        .where('isRead', '==', false)
        .count()
        .get();

    return snapshot.data().count;
}
