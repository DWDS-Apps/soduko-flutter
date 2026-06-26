# Release Recommendations — Sudoku v1.0

**Date:** 2026-06-22  
**Status:** ~94% complete (code complete, CI-blocked steps pending)

---

## Remaining Build Steps (run locally)

These two commands cannot run in this CI sandbox — run them on your development machine:

```bash
# Android (requires Android Studio + SDK)
cd soduko-flutter
flutter build apk --release

# iOS (requires macOS + Xcode)
flutter build ios --release
```

Both should pass with zero code changes — `dart analyze` is clean and `flutter build linux`/`web` have already been verified.

---

## Recommended: Set Up GitHub Actions CI

Add `.github/workflows/build.yml` to automate validation on every push:

```yaml
name: Build
on: [push]
jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - with:
          flutter-version: '3.27.4'
      - run: flutter pub get
      - run: dart analyze
      - run: flutter test
```

This replaces the cron job's manual compile checks with reliable CI that runs on every push.

---

## Stop the Cron Job

The `Sudoku Auto-Dev` cron job has completed all phases. It'll keep running every hour with nothing to do. Stop it with:

```bash
hermes cron list          # get the job ID
hermes cron remove <id>   # remove it
```

---

## Post-v1 Ideas (from PRD)

| Feature | Why |
|---|---|
| Cloud sync (Firebase) | Cross-device progress |
| Achievements | Google Play / Game Center integration |
| Leaderboards | Weekly/monthly ranked times |
| Ad monetization | Rewarded video for extra hints |
| IAP theme packs | Custom grid colors/number fonts |

---

## Publishing Checklist

- [ ] `flutter build apk --release` — produces `build/app/outputs/flutter-apk/app-release.apk`
- [ ] `flutter build ios --release` — produces `build/ios/ipa/Runner.ipa`
- [ ] Take screenshots via `flutter run` on a real device
- [ ] Upload APK to Google Play Console
- [ ] Upload IPA to App Store Connect
- [ ] Set version to 1.0.0+1 for first release
