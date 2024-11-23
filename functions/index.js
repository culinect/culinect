const {onRequest} = require("firebase-functions/v2/https");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

admin.initializeApp();

exports.handleNewMessage = onDocumentCreated("messages/{messageId}", async (event) => {
    const message = event.data.data();
    const messageId = event.params.messageId;

    const [senderSnapshot, recipientSnapshot] = await Promise.all([
        admin.firestore().collection("users").doc(message.senderId).get(),
        admin.firestore().collection("users").doc(message.recipientId).get()
    ]);

    const sender = senderSnapshot.data();
    const recipient = recipientSnapshot.data();

    await admin.firestore().collection("notifications").add({
        userId: message.recipientId,
        type: "new_message",
        title: "New Message",
        body: `${sender.fullName} sent you a message`,
        messageId: messageId,
        senderId: message.senderId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        read: false
    });

    if (recipient.fcmTokens && recipient.fcmTokens.length > 0) {
        const notification = {
            notification: {
                title: "New Message",
                body: `${sender.fullName} sent you a message`
            },
            data: {
                messageId: messageId,
                senderId: message.senderId,
                type: "new_message"
            },
            tokens: recipient.fcmTokens
        };

        try {
            await admin.messaging().sendMulticast(notification);
            logger.info("Push notifications sent successfully");
        } catch (error) {
            logger.error("Error sending push notifications:", error);
        }
    }
});

exports.handleNewRecipe = onDocumentCreated("recipes/{recipeId}", async (event) => {
    const recipe = event.data.data();
    const recipeId = event.params.recipeId;

    const userSnapshot = await admin.firestore()
        .collection("users")
        .doc(recipe.userId)
        .get();
    const user = userSnapshot.data();

    const followersSnapshot = await admin.firestore()
        .collection("followers")
        .doc(recipe.userId)
        .get();
    const followerIds = followersSnapshot.data()?.followers || [];

    for (const followerId of followerIds) {
        const followerDoc = await admin.firestore()
            .collection("users")
            .doc(followerId)
            .get();
        const follower = followerDoc.data();

        await admin.firestore().collection("notifications").add({
            userId: followerId,
            type: "recipe",
            title: "New Recipe",
            body: `${user.fullName} shared a new recipe: ${recipe.title}`,
            messageId: recipeId,
            senderId: recipe.userId,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            read: false
        });

        if (follower.fcmTokens && follower.fcmTokens.length > 0) {
            const notification = {
                notification: {
                    title: "New Recipe",
                    body: `${user.fullName} shared a new recipe: ${recipe.title}`
                },
                data: {
                    messageId: recipeId,
                    type: "recipe"
                },
                tokens: follower.fcmTokens
            };

            try {
                await admin.messaging().sendMulticast(notification);
            } catch (error) {
                logger.error("Error sending recipe notification:", error);
            }
        }
    }
});

exports.handleNewJob = onDocumentCreated("jobs/{jobId}", async (event) => {
    const job = event.data.data();
    const jobId = event.params.jobId;

    const userSnapshot = await admin.firestore()
        .collection("users")
        .doc(job.userId)
        .get();
    const user = userSnapshot.data();

    const chefsSnapshot = await admin.firestore()
        .collection("users")
        .where("role", "==", "chef")
        .get();

    for (const chefDoc of chefsSnapshot.docs) {
        const chef = chefDoc.data();

        await admin.firestore().collection("notifications").add({
            userId: chefDoc.id,
            type: "job",
            title: "New Job Opportunity",
            body: `${user.fullName} posted a new job: ${job.title}`,
            messageId: jobId,
            senderId: job.userId,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            read: false
        });

        if (chef.fcmTokens && chef.fcmTokens.length > 0) {
            const notification = {
                notification: {
                    title: "New Job Opportunity",
                    body: `${user.fullName} posted a new job: ${job.title}`
                },
                data: {
                    messageId: jobId,
                    type: "job"
                },
                tokens: chef.fcmTokens
            };

            try {
                await admin.messaging().sendMulticast(notification);
            } catch (error) {
                logger.error("Error sending job notification:", error);
            }
        }
    }
});

exports.handleNewPost = onDocumentCreated("posts/{postId}", async (event) => {
    const post = event.data.data();
    const postId = event.params.postId;

    const userSnapshot = await admin.firestore()
        .collection("users")
        .doc(post.userId)
        .get();
    const user = userSnapshot.data();

    const followersSnapshot = await admin.firestore()
        .collection("followers")
        .doc(post.userId)
        .get();
    const followerIds = followersSnapshot.data()?.followers || [];

    for (const followerId of followerIds) {
        const followerDoc = await admin.firestore()
            .collection("users")
            .doc(followerId)
            .get();
        const follower = followerDoc.data();

        await admin.firestore().collection("notifications").add({
            userId: followerId,
            type: "post",
            title: "New Post",
            body: `${user.fullName} shared a new post`,
            messageId: postId,
            senderId: post.userId,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            read: false
        });

        if (follower.fcmTokens && follower.fcmTokens.length > 0) {
            const notification = {
                notification: {
                    title: "New Post",
                    body: `${user.fullName} shared a new post`
                },
                data: {
                    messageId: postId,
                    type: "post"
                },
                tokens: follower.fcmTokens
            };

            try {
                await admin.messaging().sendMulticast(notification);
            } catch (error) {
                logger.error("Error sending post notification:", error);
            }
        }
    }
});

exports.markNotificationRead = onRequest(async (request, response) => {
    try {
        const {notificationId} = request.body;

        await admin.firestore()
            .collection("notifications")
            .doc(notificationId)
            .update({
                read: true,
                readAt: admin.firestore.FieldValue.serverTimestamp()
            });

        response.json({success: true});
    } catch (error) {
        logger.error("Error marking notification as read:", error);
        response.status(500).json({error: "Failed to mark notification as read"});
    }
});

exports.getUserNotifications = onRequest(async (request, response) => {
    try {
        const {userId, limit = 20} = request.query;

        const notificationsSnapshot = await admin.firestore()
            .collection("notifications")
            .where("userId", "==", userId)
            .orderBy("createdAt", "desc")
            .limit(parseInt(limit))
            .get();

        const notifications = [];
        notificationsSnapshot.forEach(doc => {
            notifications.push({
                id: doc.id,
                ...doc.data()
            });
        });

        response.json({notifications});
    } catch (error) {
        logger.error("Error fetching notifications:", error);
        response.status(500).json({error: "Failed to fetch notifications"});
    }
});

exports.updateFCMToken = onRequest(async (request, response) => {
    try {
        const {userId, fcmToken} = request.body;

        await admin.firestore()
            .collection("users")
            .doc(userId)
            .update({
                fcmTokens: admin.firestore.FieldValue.arrayUnion(fcmToken),
                tokenUpdatedAt: admin.firestore.FieldValue.serverTimestamp()
            });

        response.json({success: true});
    } catch (error) {
        logger.error("Error updating FCM token:", error);
        response.status(500).json({error: "Failed to update FCM token"});
    }
});
