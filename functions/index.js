const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.notifyManagerOnSubmission = functions.firestore
  .document("task_submissions/{submissionId}")
  .onCreate(async (snap, context) => {
    const submission = snap.data();

    const task = submission.task || "Unnamed Task";
    const submittedBy = submission.submittedBy;

    // Get employee's details (to fetch name and team)
    const employeeDoc = await admin.firestore()
      .collection("people")
      .doc(submittedBy)
      .get();

    if (!employeeDoc.exists) return null;

    const employeeData = employeeDoc.data();
    const employeeName = employeeData.name || "An employee";
    const teamId = employeeData.teamId;

    if (!teamId) {
      console.log("No teamId associated with employee.");
      return null;
    }

    // Find manager who has this team in their teams array
    const managerSnap = await admin.firestore()
      .collection("people")
      .where("role", "==", "manager")
      .where("teams", "array-contains", teamId)
      .limit(1)
      .get();

    if (managerSnap.empty) {
      console.log("No manager found for team:", teamId);
      return null;
    }

    const managerData = managerSnap.docs[0].data();
    const fcmToken = managerData.fcmToken;

    if (!fcmToken) {
      console.log("No FCM token found for manager.");
      return null;
    }

    const message = {
      notification: {
        title: "📩 New Task Submission",
        body: `${employeeName} submitted task: ${task}`,
      },
      token: fcmToken,
    };

    try {
      const response = await admin.messaging().send(message);
      console.log("Successfully sent notification:", response);
    } catch (error) {
      console.error("Error sending notification:", error);
    }

    return null;
  });
