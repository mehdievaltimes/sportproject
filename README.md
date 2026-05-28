# Whatever this is

**Whatever this is** is an elite sports science dashboard built natively for macOS. Designed for sports scientists, physiotherapists, and coaching staff, it provides a unified hub for tracking athlete wellness, daily load metrics, and clinical notes to optimize roster management and recovery.

## Features

* **Secure Authentication**: Built on Firebase Authentication for secure email/password sign-up and sign-in.
* **Persistent User Profiles**: Stores sports scientist metadata (First Name, Last Name, Role) natively in Cloud Firestore.
* **Interactive Data Visualization**: Leverages modern Swift Charts to render scrollable, dynamic 7-day, 28-day, and 60-day load tracking overviews.
* **Clinical Notes & Timeline**: Authors and timestamps clinical observation notes directly to an athlete's profile.
* **Injury & Rehab Status**: Visually tracks current injury states, return-to-play timelines, and flags critical status changes.

## Architecture & Tech Stack

* **Language**: Swift
* **UI Framework**: SwiftUI (macOS target, min version macOS 14.0+)
* **Backend**: Firebase / Google Cloud
  * `FirebaseAuth`: Handles session states and secure credential storage via Keychain.
  * `FirebaseFirestore`: Cloud NoSQL database to store User Profiles and (soon) Athlete metrics.

## Getting Started

### Prerequisites

1. Xcode 15 or later.
2. A Firebase Project configured with an iOS/macOS App.

### Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/mehdievaltimes/sportproject
   cd sportproject
   ```

2. **Add Firebase Credentials**:
   Download your `GoogleService-Info.plist` from your Firebase Console and drop it directly into the root folder (`/sportproject/`).

3. **Install Dependencies**:
   The project uses Swift Package Manager (SPM). Open the `.xcodeproj` file in Xcode, and SPM will automatically resolve `firebase-ios-sdk`. Ensure the following libraries are linked:
   * `FirebaseAuth`
   * `FirebaseFirestore`
   * `FirebaseCore`


## Future Roadmap

- [ ] Transition Athlete & MockData models to fully sync with Firestore.
- [ ] iOS Companion app for athletes to submit daily wellness questionnaires.
- [ ] HealthKit integration for parsing raw wearable data into the daily load metrics.
