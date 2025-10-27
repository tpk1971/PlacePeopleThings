PlacePeopleThingsFE

Flutter frontend for PlacePeopleThingsAPI.

This is a minimal starter. To enable platforms (web, windows, linux) run from this folder:

  flutter create . --platforms=web,windows,linux

Then run the app for each platform, for example (web):

  flutter run -d chrome --dart-define=API_BASE=http://localhost:3000

Pass --dart-define=API_BASE to point the app at a different API base URL.

