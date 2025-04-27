# HR Tracker Assessment

This is the HR Tracker Flutter application developed for the technical assessment.  
It covers user authentication, profile management, and logout functionalities with proper API integration and responsive UI.

---

## How to Run

1. **Clone the repository**:

```bash
git clone https://github.com/RoentgeniumR/assessment_hr_tracker.git
```

2. **Navigate to the project directory**
```
cd assessment_send
```
3. **Install Flutter dependencies**
```
flutter pub get
```
4. **Run the app:**
```
flutter run
```

---

### What Was Implemented
```Task 1: Logout Animation
Replaced default logout navigation with a slide-down animation.

Used PageRouteBuilder and SlideTransition for a smooth transition to the LoginScreen after logout.
```
```Task 2: Email Validation
Added real-time email validation for the username field.

Displayed appropriate error messages for invalid email formats.

Disabled the Login button if either the email or password fields are invalid.
```
```Task 3: Logout API Call
Integrated a POST /api/logout API call when the user logs out.

Handled both success and failure scenarios:

Success: Navigates back to the Login screen with animation.

Failure: Shows a Snackbar error message, then navigates back to ensure smooth UX.
```
```Task 4: Fix Save Button Overflow
Resolved overflow issues when the keyboard pops up on the Details Screen.

Wrapped the form inside a SingleChildScrollView and enabled resizeToAvoidBottomInset on Scaffold.

Ensured that users can always reach the Save button regardless of screen size or keyboard visibility.
```