/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v1/https");
const logger = require("firebase-functions/logger");
const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// Import the usersFunction
const {usersFunction} = require("./usersFunction");

// Export the usersFunction
exports.usersFunction = usersFunction;
