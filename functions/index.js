/**
 * Firebase Cloud Functions for Car Dealer App
 * 
 * Sends FCM push notifications to sellers when a buyer enquires about their car.
 */

const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

/**
 * Triggered when a new notification is written to a seller's /notifications subcollection.
 * Looks up the seller's FCM token and sends a push notification to their device.
 */
exports.sendPushOnSellerNotification = functions.firestore
  .document("users/{sellerId}/notifications/{notificationId}")
  .onCreate(async (snapshot, context) => {
    const data = snapshot.data();
    const sellerId = context.params.sellerId;

    // Only send push for allowed notification types
    if (data.type !== "car_inquiry" && data.type !== "admin_message") {
      console.log(`Skipping notification type: ${data.type}`);
      return null;
    }

    try {
      // Get seller's FCM token
      const sellerDoc = await db.collection("users").doc(sellerId).get();
      if (!sellerDoc.exists) {
        console.log(`Seller/User ${sellerId} not found`);
        return null;
      }

      const sellerData = sellerDoc.data();
      const fcmToken = sellerData.fcmToken;

      if (!fcmToken || fcmToken.length === 0) {
        console.log(`No FCM token for user ${sellerId}`);
        return null;
      }

      let title = "New Notification";
      let body = "You have a new notification";
      let payloadData = {
        type: data.type,
        notificationId: context.params.notificationId,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      };

      if (data.type === "car_inquiry") {
        const buyerName = data.buyerName || "Someone";
        const carName = data.carName || "";
        const carModel = data.carModel || "";
        const carPrice = data.carPrice || "";

        title = "New Car Enquiry! 🚗";
        body = `${buyerName} is interested in your ${carName} ${carModel}${carPrice ? " (₹" + carPrice + ")" : ""}`;
        
        payloadData.buyerName = buyerName;
        payloadData.carName = carName;
        payloadData.carModel = carModel;
        payloadData.carPrice = String(carPrice);
      } else if (data.type === "admin_message") {
        title = data.title || "Message from Admin";
        body = data.message || "You have a new message from the administrator.";
        
        if (data.imageUrl) payloadData.imageUrl = data.imageUrl;
        if (data.buttonAction) payloadData.buttonAction = data.buttonAction;
      }

      const message = {
        token: fcmToken,
        notification: {
          title: title,
          body: body,
        },
        data: payloadData,
        android: {
          priority: "high",
          notification: {
            channelId: "car_dealer_notifications",
            priority: "high",
            defaultSound: true,
            defaultVibrateTimings: true,
            icon: "launcher_icon",
          },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      };

      const response = await messaging.send(message);
      console.log(`Push sent to seller ${sellerId}: ${response}`);
      return response;
    } catch (error) {
      // If the token is invalid/expired, clean it up
      if (
        error.code === "messaging/invalid-registration-token" ||
        error.code === "messaging/registration-token-not-registered"
      ) {
        console.log(`Removing stale FCM token for seller ${sellerId}`);
        await db.collection("users").doc(sellerId).update({
          fcmToken: "",
        });
      } else {
        console.error(`Error sending push to seller ${sellerId}:`, error);
      }
      return null;
    }
  });

/**
 * Triggered when a new admin_notification is created.
 * Sends a push to all admins so they are instantly alerted of new enquiries.
 */
exports.sendPushOnAdminNotification = functions.firestore
  .document("admin_notifications/{notificationId}")
  .onCreate(async (snapshot, context) => {
    const data = snapshot.data();

    // Only push for car_inquiry
    if (data.type !== "car_inquiry") return null;

    try {
      // Get all admin user IDs
      const adminsSnapshot = await db.collection("admins").get();
      if (adminsSnapshot.empty) {
        console.log("No admins found");
        return null;
      }

      const buyerName = data.buyerName || "Someone";
      const carName = data.carName || "";
      const carModel = data.carModel || "";

      const title = "New Enquiry Received";
      const body = `${buyerName} enquired about ${carName} ${carModel}`;

      // Send push to each admin
      const promises = adminsSnapshot.docs.map(async (adminDoc) => {
        const adminId = adminDoc.id;
        try {
          const userDoc = await db.collection("users").doc(adminId).get();
          if (!userDoc.exists) return null;

          const fcmToken = userDoc.data().fcmToken;
          if (!fcmToken) return null;

          return messaging.send({
            token: fcmToken,
            notification: { title, body },
            data: {
              type: "admin_car_inquiry",
              click_action: "FLUTTER_NOTIFICATION_CLICK",
            },
            android: {
              priority: "high",
              notification: {
                channelId: "car_dealer_notifications",
                priority: "high",
                defaultSound: true,
              },
            },
          });
        } catch (e) {
          console.log(`Error sending to admin ${adminId}: ${e.message}`);
          return null;
        }
      });

      await Promise.all(promises);
      console.log("Admin push notifications sent");
      return null;
    } catch (error) {
      console.error("Error sending admin notifications:", error);
      return null;
    }
  });

/**
 * Triggered when a user document is deleted from the users collection.
 * Automatically deletes the corresponding Firebase Auth account.
 */
exports.deleteUserAccount = functions.firestore
  .document("users/{userId}")
  .onDelete(async (snap, context) => {
    const userId = context.params.userId;
    try {
      await admin.auth().deleteUser(userId);
      console.log(`Successfully deleted auth user: ${userId}`);
    } catch (error) {
      if (error.code === 'auth/user-not-found') {
        console.log(`Auth user ${userId} already deleted or not found.`);
      } else {
        console.error(`Error deleting auth user ${userId}:`, error);
      }
    }
  });
