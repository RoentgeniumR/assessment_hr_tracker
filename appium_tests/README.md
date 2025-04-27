# Appium E2E Testing Setup for HR Tracker App

This guide documents the full setup for running E2E (End-to-End) Appium tests on the **HR Tracker App**.

---

## 📦 Project Structure

```plaintext
assessment_hr_tracker/
 └── appium_tests/
     ├── node_modules/
     ├── test/
     │    └── specs/
     │         └── test.e2e.js
     ├── app-release.apk
     ├── package.json
     ├── package-lock.json
     ├── wdio.conf.js
     └── README.md
```

---

### Step by step for appuium setup

1. Install dependencies
```
npm install @wdio/cli @wdio/local-runner @wdio/mocha-framework appium appium-adb appium-uiautomator2-driver webdriverio
```

2. Appium Server
```
appium

It should be listening on:
http://localhost:4723

```

3. Run the E2E Test
```
npx wdio run wdio.conf.js
```

#### This will automatically:

- Open the app
- Login
- Add a new profile
- Logout
- Validate everything