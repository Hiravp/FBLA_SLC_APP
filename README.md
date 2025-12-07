# fbla_member_app

A new Flutter project.

# FBLA_SLC_APP
Before download and run flutter:
1. Install Xcode (Required for iOS)
xcode-select --install


Then open the App Store → search Xcode → download it.

After installing:

sudo xcodebuild -license accept

2. Install Homebrew (if you don’t already have it)

Homebrew is needed for tools like Git, CocoaPods.

Run in terminal:

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"


Update your environment:

echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

3. Use Homebrew to install required tools
Install Git
brew install git

Install fvm (optional but recommended)

This lets you manage Flutter versions easily:

brew install fvm

4. Download Flutter SDK
Option A — Using FVM (recommended)
fvm install stable
fvm global stable

Option B — Manual download
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable


Add Flutter to PATH:

echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zshrc
source ~/.zshrc

5. Install CocoaPods

Needed for iOS builds:

sudo gem install cocoapods


Or via Homebrew:

brew install cocoapods

6. Run flutter doctor
flutter doctor


This checks everything. Fix whatever is missing.

7. Accept Android licenses (if you want Android development)

Install Android Studio → open it → install SDK + plugins.

Then:

flutter doctor --android-licenses

8. (Optional) Install VS Code or Android Studio plugins
VS Code:

Extensions → install:

Flutter

Dart

Android Studio:

Preferences → Plugins → Install:

Flutter

Dart

You’re done

After this you can create a project:

flutter run

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

