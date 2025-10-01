// autoMarkNotChecked.js
const { Firestore } = require("@google-cloud/firestore");

// Đọc Service Account từ biến môi trường (GitHub Secret)
if (!process.env.FIREBASE_TOKEN_PHUC) {
  console.error("❌ Missing FIREBASE_TOKEN_PHUC env variable");
  process.exit(1);
}

// Parse JSON
let serviceAccount;
try {
  serviceAccount = JSON.parse(process.env.FIREBASE_TOKEN_PHUC);
} catch (err) {
  console.error("❌ Invalid FIREBASE_TOKEN_PHUC JSON");
  process.exit(1);
}


// Khởi tạo Firestore client
const firestore = new Firestore({
  projectId: serviceAccount.project_id,
  credentials: {
    client_email: serviceAccount.client_email,
    private_key: serviceAccount.private_key.replace(/\\n/g, '\n'),
  },
});

async function autoMarkNotChecked() {
  const today = new Date();
  const startOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 0, 0, 0);
  const endOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 23, 59, 59);

  const startTs = Firestore.Timestamp.fromDate(startOfDay);
  const endTs = Firestore.Timestamp.fromDate(endOfDay);

  const usersSnap = await firestore.collection("userLogin").get();
  let updatedCount = 0;

  for (const userDoc of usersSnap.docs) {
    const userData = userDoc.data();

    // Kiểm tra đã có điểm danh hôm nay chưa
    const attendanceSnap = await firestore
      .collection("attendanceqr")
      .where("uid", "==", userDoc.id)
      .where("timestamp", ">=", startTs)
      .where("timestamp", "<=", endTs)
      .limit(1)
      .get();

    if (attendanceSnap.empty) {
      await firestore.collection("attendanceqr").add({
        uid: userDoc.id,
        name: userData.name || "",
        phone: userData.phone || "",
        status: "NOT_CHECKED",
        note: "Quá giờ điểm danh",
        method: "AUTO",
        timestamp: Firestore.Timestamp.now(),
      });
      updatedCount++;
    }
  }

  console.log(`✅ Đã cập nhật ${updatedCount} sinh viên chưa điểm danh thành NOT_CHECKED`);
}

autoMarkNotChecked().catch((err) => {
  console.error("❌ Lỗi khi chạy autoMarkNotChecked:", err);
  process.exit(1);
});