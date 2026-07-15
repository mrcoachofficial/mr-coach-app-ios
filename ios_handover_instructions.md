# 🚀 Instructions for Flutter iOS App Store Release

Please follow these steps to build, sign, and upload the **Mr Coach** iOS application to App Store Connect / TestFlight:

---

## 📋 Part 1: Access & Project Details
* **Git Repo:** `https://github.com/mrcoachofficial/mr-coach-app-ios.git`
* **Bundle ID:** `com.mrcoachclient.app`
* **Apple Developer Team:** `Mohamed Jaffer / Mr Coach` (Login: `mrcoachofficial@gmail.com`)

---

## 🛠️ Part 2: Step-by-Step Implementation Guide

### **Step 1: Clone the Code**
Open Terminal on your Mac and clone the repo:
```bash
git clone https://github.com/mrcoachofficial/mr-coach-app-ios.git
cd mr-coach-app-ios
```

### **Step 2: Fetch Dependencies**
Run the flutter and pod commands to sync dependencies:
```bash
flutter pub get
cd ios
pod install
cd ..
```

### **Step 3: Add Apple ID to Xcode Accounts**
1. Open **Xcode** on your Mac.
2. Go to the top menu: **Xcode > Settings** (or **Preferences**), then select the **Accounts** tab.
3. Click the **`+`** icon at the bottom-left, select **Apple ID**, and sign in with: `mrcoachofficial@gmail.com`.

### **Step 4: Open Workspace & Configure Code Signing**
1. Open the project workspace in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
2. In Xcode’s left sidebar, select the top-level **Runner** project.
3. In the main editor panel, select the **Signing & Capabilities** tab.
4. Check **"Automatically manage signing"**.
5. Under **Team**, select the **Mohamed Jaffer / Mr Coach** team.
6. Ensure the Bundle Identifier field displays: `com.mrcoachclient.app`.

### **Step 5: Archive and Upload to App Store Connect**
1. In the top bar of Xcode, change the run destination dropdown from a Simulator to **Any iOS Device (arm64)**.
2. From the top menu bar, select **Product > Archive**.
3. Wait for the build to finish. The **Organizer** window will pop up.
4. Click **Distribute App** on the right panel.
5. Choose **App Store Connect** -> **Upload** and follow the prompts to push the build to TestFlight.
