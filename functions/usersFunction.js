const functions = require("firebase-functions");
const admin = require("firebase-admin");
const cors = require('cors')({origin: true});

const db = admin.firestore();

exports.usersFunction = functions.https.onRequest(async (req, res) => {
    try {
        // Extract user ID from URL path
        const userId = req.path.split('/')[2];

        if (!userId) {
            console.error('User ID not found in request path');
            res.status(400).send('Bad Request: User ID not found');
            return;
        }

        const userDoc = await db.collection('users').doc(userId).get();


        if (!userDoc.exists) {
            res.status(404).send("User not found");
            return;
        }

        // Extract user data
        const userData = userDoc.data();
        const { fullName, bio, profilePicture, profileLink } = userData;

        // Construct HTML response with Open Graph metadata
        const htmlResponse = `
            <html>
            <head>
                <meta property="og:title" content="${fullName}">
                <meta property="og:description" content="${bio}">
                <meta property="og:image" content="${profilePicture}">
                <meta property="og:url" content="${profileLink}">
            </head>
            <body>
                <h1>${fullName}</h1>
                <p>${bio}</p>
                <img src="${profilePicture}" alt="${fullName}">
                <a href="${profileLink}">Visit Profile</a>
            </body>
            </html>
        `;

        // Respond with HTML content
        res.set('Content-Type', 'text/html');
        res.status(200).send(htmlResponse);
    } catch (error) {
        console.error("Error:", error);
        res.status(500).send("Internal Server Error");
    }
});
