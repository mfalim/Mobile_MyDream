# w51

A new Flutter project.

## API configuration

The shared API client reads its base URL from the `API_BASE_URL` compile-time
variable. By default it targets a Laravel API running on the Android emulator at
`http://10.0.2.2:8000/api/`. Override it for another environment:

```shell
flutter run --dart-define=API_BASE_URL=https://example.com/api/
```

Keep the `/api/` prefix in the base URL and pass endpoint paths without a
leading slash (for example, `vendors`) so it is only included once. Use your
computer's LAN IP when testing on a physical device, and HTTPS for production.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
"# Mobile_MyDream" 
