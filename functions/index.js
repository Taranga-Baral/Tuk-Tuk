const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Reference to Firestore
const db = admin.firestore();

// Define the HTTP function
exports.getDeliveryInfo = functions.https.onRequest(async (req, res) => {
  try {
    // Get data from Firestore
    const snapshot = await db.collection("trips").get();
    if (snapshot.empty) {
      return res.status(404).send("No data found.");
    }
    // Process data
    const data = [];
    snapshot.forEach((doc) => {
      data.push({id: doc.id, ...doc.data()});
    });

    // Send the data as JSON
    return res.status(200).json(data);
  } catch (error) {
    console.error("Error retrieving data:", error);
    return res.status(500).send("Internal Server Error");
  }
});
