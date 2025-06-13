
# 📌 Commit Tracker App

**Commit Tracker App** is a mobile application built with **Flutter**, designed to help developers stay consistent with their GitHub commit streaks. With personalized streak tracking, notifications, and visual progress indicators, it's your accountability partner for daily coding.

## 🚀 Features

* 🔥 Daily GitHub commit streak tracking
* ⏰ Smart reminders when you haven’t committed yet
* 📊 Visual indicators: flame colors change based on streak milestones (e.g., 200, 500, 1000 days)
* 🗂️ Dashboard showing total commits
* 🔐 Secure login via **Firebase Authentication**
* ☁️ Real-time storage using **Cloud Firestore**

## 🧰 Tech Stack

* **Flutter** – Cross-platform mobile development
* **Firebase** – Auth & Firestore for backend
* **GitHub API** – Uses **Personal Access Token (PAT)** to retrieve commit data securely

## 📸 Screenshots

> *Coming soon*

## ⚙️ Getting Started

1. **Clone the repository**

   ```bash
   git clone https://github.com/difadlyaulhaq/commit_tracker_app.git
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Set up Firebase**

   * Add your `google-services.json` and `GoogleService-Info.plist` files
   * Enable Email/Password or Google Auth in Firebase

4. **Add GitHub PAT (Personal Access Token)**

   * Store securely in your app or Firestore (never hard-code in public)

5. **Run the app**

   ```bash
   flutter run
   ```

## 📄 License

MIT License – free to use and modify.
