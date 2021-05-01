const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.myFunction = functions.firestore
    .document("chat/{message}")
    .onCreate((snap, context) => {
      const newMessage = snap.data();
      admin.messaging().sendToTopic("chat", {
        notification: {
          title: newMessage.username,
          body: newMessage.text,
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
      });
    });
