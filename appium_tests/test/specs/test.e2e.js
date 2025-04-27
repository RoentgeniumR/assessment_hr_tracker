describe('HR Tracker App E2E Test', () => {
    it('should login, add a new profile, and logout', async () => {
      try {
        console.log('🚀 Starting Login -> Create Profile -> Logout Flow');
  
        // ========== LOGIN ==========
        const usernameField = await $('//android.widget.EditText[1]');
        const passwordField = await $('//android.widget.EditText[2]');
        const loginButton = await $('~Login');
  
        await usernameField.click();
        await usernameField.setValue('candidate_01@alex.dev');
        await passwordField.click();
        await passwordField.setValue('123');
        await loginButton.click();
  
        // ========== WAIT FOR PROFILES ==========
        const profilesTitle = await $('~Profiles');
        await profilesTitle.waitForDisplayed({ timeout: 5000 });
  
        // ========== TAP FAB (Add Profile) ==========
        const fabButton = await $('//android.widget.Button[@class="android.widget.Button" and @index="2"]');
        await fabButton.waitForDisplayed({ timeout: 5000 });
        await fabButton.click();
  
        // ========== FILL PROFILE FORM ==========
        const firstNameField = await $('//android.widget.EditText[1]');
        const lastNameField = await $('//android.widget.EditText[2]');
        const notesField = await $('//android.widget.EditText[3]');
        const saveButton = await $('~Save');
  
        await firstNameField.click();
        await firstNameField.setValue('John');
        await lastNameField.click();
        await lastNameField.setValue('Doe');
        await notesField.click();
        await notesField.setValue('Test notes for John Doe');
  
        // ========== EXIT keyboard ==========
        await driver.back(); // <-- this will close the keyboard
        await driver.pause(500); // (optional small pause)

        // Now click Save
        await saveButton.waitForDisplayed({ timeout: 5000 });
        await saveButton.click();
  
        // ========== BACK TO PROFILES ==========
        await profilesTitle.waitForDisplayed({ timeout: 5000 });
  
        // ========== LOGOUT ==========
        const logoutButton = await $('//android.widget.Button[@index="1"]');
        await logoutButton.click();
  
        const confirmLogoutButton = await $('~Logout');
        await confirmLogoutButton.waitForDisplayed({ timeout: 3000 });
        await confirmLogoutButton.click();
  
        // ========== BACK TO LOGIN ==========
        await loginButton.waitForDisplayed({ timeout: 5000 });
  
        console.log('✅ E2E Test Passed Successfully!');
      } catch (error) {
        console.error('❌ Test Failed:', error.message);
        throw error;
      }
    });
  });
  