# credo

Catholic community app for Japan

## Overview

Credo is a Flutter mobile application that connects Catholic churches and believers across Japan. The app provides daily meditations, parish information, community features, and more.

## Features

- **Daily Meditations**: Access daily Bible readings and prayer guides
- **Parish Directory**: Search and find Catholic churches across Japan with mass schedules
- **Community**: Connect with other believers through posts and comments
  - Create posts with images (up to 3) and PDF files (up to 2)
  - Add comments with images (up to 2) and PDF files (up to 1)
  - In-app PDF viewer with zoom and text selection
  - Full image display with proper aspect ratio
  - Notification type distinction (new posts, comments, notices)
- **Multilingual Support**: Available in 7 languages (Japanese, English, Korean, Chinese, Vietnamese, Spanish, Portuguese)
- **Location-based Services**: Find nearby churches and view distances
- **User Profiles**: Manage your profile, favorite parishes, and settings
- **Saint Feast Days**: Daily saint feast day modal with AI-generated celebration messages
  - Personalized messages when your baptismal name matches the saint
  - Shown once per day (first app launch)
  - Displays saint images (or Credo logo if unavailable)
- **Grouped Notifications**: Parish-based notification grouping with accordion
  - Notifications grouped by parish
  - Parish name header with expand/collapse icon
  - Collapsed by default for better space efficiency
  - Up to 5 notifications per parish

## Internationalization

The app supports 7 languages:
- 🇯🇵 Japanese (日本語) - Default
- 🇺🇸 English
- 🇰🇷 Korean (한국어)
- 🇨🇳 Chinese (中文)
- 🇻🇳 Vietnamese (Tiếng Việt)
- 🇪🇸 Spanish (Español)
- 🇵🇹 Portuguese (Português)

Translation files are located in `assets/l10n/`:
- `app_ja.json` - Japanese (base language)
- `app_en.json` - English
- `app_ko.json` - Korean
- `app_zh.json` - Chinese
- `app_vi.json` - Vietnamese
- `app_es.json` - Spanish
- `app_pt.json` - Portuguese

Users can change the language in Settings > Language Settings.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Architecture

This project follows Clean Architecture principles with feature-based modules. See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for detailed architecture documentation.
