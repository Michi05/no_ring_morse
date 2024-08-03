
testing github sync

Next steps:

[x] Add a scrollable box with a list of files in the default path
[x] When I select an audio file from the list, I can click on 'play' to play it or 'share' to export it to another app or save it manually. The 'share' button will be aligned to the right of the 'play' button.
[x] Can we provide some light gray styling to the list box so that the user can see where it is, and also limit the height to allow seeing only the top 3 items but allowing scrolling to see the rest? 
[x] Allow deleting files too
[x] Load list on init
[x] Fix sharing functionality
[x] Fix context menu
[x] Icons, title, styling
[x] Generate Apk to share with David
[x] Make the Apk -release- mode and lighter
 - Change both the android manifest and command line; remember to undo!
 - Build command for ARM64 architecture
[ ] Use Mp3 instead of wav




## Tools
#### Icon Generator:
Icon Kitchen:
- [Icon Kitchen](https://icon.kitchen/i/H4sIAAAAAAAAAz2Py2oDMQxF%2F0XdzqItlNLZli4LhXZXSpEtyWPiGU38SAgh%2Fx55AtnY4uhx7z3DAVPjAuMZCPPuZ%2BKZYRRMhQeQ8J7iirn2dmH7gFiwpQoDRK%2BLgRRdxnz6n1uJHi7bkibN1noQESdisxI%2BRNhX04EyIelxg19IFJfQr1ddYXx6GSDHMJlQL53WqvOtTiwbNQGHFMwjfGoubHdc%2BJ5w7aTsW8w%2BdVh7ELon2Xbuvt7886t77GZnpZZ6%2FF%2FAhbJG6sm02HtkB3%2BXK5dl8%2BIhAQAA)
(by https://roman.nurik.net/)
- [EasyAppIcon](https://easyappicon.com/)

#### Known issues found:
- share_plus duplicate ...whatever...:
https://gist.github.com/danielcshn/7aa57155d766d46c043fde015f054d40
https://stackoverflow.com/questions/77181003/duplicate-class-kotlin-internal-jdk7-jdk7platformimplementations-found-in-module
https://github.com/fluttercommunity/plus_plugins/issues/1673

- Fixing issues with environment variables, java, etc...
https://github.com/auth0/auth0-flutter/issues/458
...but...
https://docs.flutter.dev/release/breaking-changes/flutter-gradle-plugin-apply

```cmd
cd C:\Users\garle\Desktop\pytest\morse_flutter\no_ring_morse\android
set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr
.\gradlew clean
.\gradlew build
./gradlew installDebug ## Probably not for me
```

##### Build APK 
flutter build apk --target-platform android-arm64 --release

