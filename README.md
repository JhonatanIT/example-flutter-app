# example_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Add permission
* Add **permission_handler** in the **pubspec.yaml** file
* Add the permissions in the **AndroidManifest.xml** file, for example:

        <uses-permission android:name="android.permission.WRITE_EXTER*NAL_STORAGE" />
* Request the permission in your code, for instance:

        if (await Permission.storage.request().isGranted) {
            ...
        } else {
            Map<Permission, PermissionStatus> statuses = await [Permission.storage].request();
        }
## Generate artefact
Run the following codes depending on the OS:
 - Android

        flutter build apk --split-per-abi


## Install an APK on a device

    flutter build apk
    flutter install
