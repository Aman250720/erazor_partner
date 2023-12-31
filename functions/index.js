const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.notifyCustomer = functions.runWith(
  {
    enforceAppCheck: true
  }
).region('asia-south1').https.onCall(async (data, context) => {
    const message = {
        notification: {
          title: 'Oh, no! Booking cancelled! 🥺🥺',
          body: data.salon + ' has cancelled your booking of ' + data.date + ' at ' + data.time + '!',
        },
        token: data.token,
      };

      try {
        const response = await admin.messaging().send(message);
        console.log('Notification sent:', response);
        return response;
      } catch (error) {
        console.error('Error sending notification:', error);
      }

});
