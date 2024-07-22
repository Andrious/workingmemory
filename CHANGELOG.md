
## 1.13.0
 July 21, 2024
- Updated import statements to exclude package name

## 1.12.0
 December 01, 2023
- Updated Flutter and dependencies
- Updated Translations
- Made Time-zone aware
- Updated Loading Screen
- Updated Settings Screen
- Allow the editing of icons, colors, and phone sounds

## 1.11.0
 January 04, 2023
- Updated gradle (jcenter to mavenCentral, 23 min 33 sdk, etc.)
- Sync process rewrite
- mvc_application to fluttery_framework library
- General rewrite to meet latest version of Flutter

## 1.10.0
 December 15, 2022
- AppMenu<String>
- if (init && !kIsWeb) {
- Draggable Floating button
- todos_page rewrite

## 1.9.0
 February 02, 2022
- Upgraded code

## 1.8.0
 November 09, 2020
- Enhanced 'Dark Mode' feature
- Introduced Widget & Async error handling.
- Changed runApp.reportError to runApp.errorReport

## 1.7.0
 November 02, 2020
- Update to mvc_application 6.1.0
- Removed class WorkingView to use class, AppState
- Introduce 'Dark Mode' switch to the App.
- Avoid infinite loops with constructor calls moved to initAsync()
- Remove an Anonymous sign in with a user login.
- Enhanced 'local' sync of offline records
- Utilize the DatabaseReference's onChildAdded() function for live syncing of device changes.

## 1.6.0
 October 16, 2020
- Removed data field, ReminderEpoch Long.
- Delete Firebase records more than a year old.
- Updated notifications.dart to consider timezones.
- More multi-language dialogue windows.
- Cancel a notification before modifying it.

## 1.5.0
 October 11, 2020
- Allowing buttons to switch around.

## 1.4.0
 October 10, 2020
- Introduced i10n.csv for translations.
- iso_spinner.dart.
- flutter_local_notifications.dart updated.

## 1.3.0
 September 25, 2020
- flutter_local_notifications package was installed.
 
## 1.2.0
 August 14, 2020
- Introduced analysis_options.yaml with strict Dart style guide.

## 1.1.0+2
 July 12, 2020
- WorkMenu in iOS interface

## 1.1.0
 July 10, 2020
- CupertinoTabScaffold to CupertinoPageScaffold
- Use of showCupertinoModalPopup

## 1.0.0
 July 06, 2020
- Change semantic versioning to major first release.
- Scaffold.of(context)
- con.data.linkForm(

## 0.17.1
 July 04, 2020
- .gitignore 

## 0.17.0
 July 04, 2020
- if (map != null) icon = map['Icon'];
- add google-services.json 
- git rm --cached -r .packages

## 0.16.0
 July 03, 2020
 - Podfile platform :ios, '10'
 - channel dev
 - GoogleService-Info.plist

## 0.15.0
 July 01, 2020
- Updated AppIcon & LaunchImage

## 0.14.0
 July 01, 2020
- primaryColor: App.color,
- 49 files committed.

## 0.13.0
- Updated README.md

## 0.12.0
- App.themeData; WorkingMemoryApp to WorkingController; View to WorkingView
- exclude much of ios/ in .gitignore

## 0.11.0
- saveFirebase(newRec); bool itemsOrdered([bool ordered]); 
- "$select order by datetime(DateTime)"; 
- requery(); 
- settitngs_drawer.dart

## 0.10.0
- Modify .gitignore file to allow committing android and ios files & folders

## 0.9.0
- SignIn(); in Menu; crash.enableInDevMode = true; Future<bool> recordDump();

## 0.8.0
- _auth.listener = _con.recordDump;
- Save favourite icons data table
- remote_config: ^1.0.0
- auth: ^6.0.0
- class DataFields

## 0.7.0
- Updated to mvc_application 5.0.0 
- Crashlytics

## 0.6.0
- class CloudDB, class RemoteConfig, class DateTimeItem
- class WorkMenu, class Icons, class LoginInfo signInSilently(), class Model FireBaseDB()
- class Semaphore, class Settings getLeftHanded()
- class SignIn signInWithFacebook(), signInWithTwitter(), signInEmailPassword(), signInWithGoogle()
- class SyncDB
- class TodoPage ? TodoAndroid() : TodoiOS();

## 0.5.0
 Feb. 26, 2020
- Changed from all Static methods.

## 0.4.0
 Feb. 21, 2020
- new dbutils

## 0.3.0
 Apr. 11, 2019
- Incorporate mxc_application

## 0.2.0
 Jan. 01, 2019
- Incorporate mvc_pattern 3.0

## 0.1.0
 Jan. 01, 2019
- Initial Commit
