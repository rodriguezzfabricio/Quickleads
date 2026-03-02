## iOS (App Store)
- [ ] App icon (1024x1024) added to ios/Runner/Assets.xcassets
- [ ] Launch screen configured in ios/Runner/LaunchScreen.storyboard
- [ ] Info.plist privacy descriptions:
  - [ ] NSCameraUsageDescription (job photos)
  - [ ] NSPhotoLibraryUsageDescription (job photos)
  - [ ] NSContactsUsageDescription (if using contacts)
- [ ] Bundle ID set: com.crewcommand.app
- [ ] Minimum iOS version: 15.0
- [ ] TestFlight build uploaded and tested

## Android (Play Store)
- [ ] App icon added to android/app/src/main/res/
- [ ] Permissions declared in AndroidManifest.xml:
  - [ ] READ_PHONE_STATE, READ_CALL_LOG
  - [ ] CAMERA, READ_MEDIA_IMAGES
  - [ ] INTERNET, ACCESS_NETWORK_STATE
  - [ ] RECEIVE_BOOT_COMPLETED
- [ ] Signing key generated and configured
- [ ] minSdkVersion: 24
- [ ] targetSdkVersion: 34+
- [ ] Internal testing track uploaded

## Both Platforms
- [ ] App name: CrewCommand
- [ ] Version: 1.0.0+1
- [ ] Deep links configured (if applicable)
- [ ] Crash reporting integrated (Sentry or Firebase Crashlytics)
- [ ] Analytics for key flows (lead capture, estimate sent, job created)
