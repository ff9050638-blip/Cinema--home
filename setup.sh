#!/usr/bin/env bash
set -e
echo "Creating Cinema Home Stage 1 files..."

mkdir -p .github/workflows .devcontainer gradle/wrapper
mkdir -p app/src/main/java/com/cinemahome
mkdir -p app/src/main/res/layout app/src/main/res/values app/src/main/res/drawable

# ---------- .gitignore ----------
cat > .gitignore <<'CH_EOF'
.gradle/
build/
local.properties
.idea/
*.iml
captures/
.DS_Store
CH_EOF

# ---------- README ----------
cat > README.md <<'CH_EOF'
# Cinema Home

A minimal, cinematic Android TV launcher (work in progress).

Stage 1: build skeleton with a TV-ready manifest and a focus test button.

## Build in the cloud
Open the Actions tab, run "Build debug APK", then download the
"CinemaHome-debug-apk" artifact from the finished run.

## Versions
Java 17, Gradle 8.7, Android Gradle Plugin 8.5.2, Kotlin 1.9.24,
compileSdk 34, minSdk 21.
CH_EOF

# ---------- Gradle settings ----------
cat > settings.gradle.kts <<'CH_EOF'
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "CinemaHome"
include(":app")
CH_EOF

cat > build.gradle.kts <<'CH_EOF'
plugins {
    id("com.android.application") version "8.5.2" apply false
    id("org.jetbrains.kotlin.android") version "1.9.24" apply false
}
CH_EOF

cat > gradle.properties <<'CH_EOF'
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
android.nonTransitiveRClass=true
kotlin.code.style=official
CH_EOF

cat > gradle/wrapper/gradle-wrapper.properties <<'CH_EOF'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.7-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
CH_EOF

# ---------- App module ----------
cat > app/build.gradle.kts <<'CH_EOF'
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.cinemahome"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.cinemahome"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "0.1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.13.1")
}
CH_EOF

cat > app/src/main/AndroidManifest.xml <<'CH_EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- This app is for Android TV, and a touchscreen is not needed -->
    <uses-feature
        android:name="android.software.leanback"
        android:required="true" />
    <uses-feature
        android:name="android.hardware.touchscreen"
        android:required="false" />

    <application
        android:allowBackup="false"
        android:icon="@drawable/ic_launcher"
        android:banner="@drawable/banner"
        android:label="@string/app_name"
        android:theme="@style/Theme.CinemaHome">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTask"
            android:screenOrientation="landscape">

            <!-- Shows the app in the Android TV app list -->
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LEANBACK_LAUNCHER" />
            </intent-filter>

            <!-- Makes the app eligible to be chosen as the Home screen -->
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.HOME" />
                <category android:name="android.intent.category.DEFAULT" />
            </intent-filter>
        </activity>
    </application>
</manifest>
CH_EOF

cat > app/src/main/java/com/cinemahome/MainActivity.kt <<'CH_EOF'
package com.cinemahome

import android.app.Activity
import android.os.Bundle
import android.widget.TextView
import android.widget.Toast

class MainActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val testButton = findViewById<TextView>(R.id.test_button)
        testButton.setOnClickListener {
            Toast.makeText(this, getString(R.string.ok_works), Toast.LENGTH_SHORT).show()
        }
        testButton.requestFocus()
    }

    // A launcher is the "bottom" screen, so Back should do nothing.
    @Suppress("OVERRIDE_DEPRECATION")
    override fun onBackPressed() {
        // intentionally empty
    }
}
CH_EOF

cat > app/src/main/res/layout/activity_main.xml <<'CH_EOF'
<?xml version="1.0" encoding="utf-8"?>
<!-- Padding of 48dp x 27dp is the standard 5% TV safe margin on a 960x540dp screen -->
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@color/background"
    android:gravity="center"
    android:orientation="vertical"
    android:paddingLeft="48dp"
    android:paddingTop="27dp"
    android:paddingRight="48dp"
    android:paddingBottom="27dp">

    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="@string/app_name"
        android:textColor="@color/text_primary"
        android:textSize="48sp" />

    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginTop="8dp"
        android:text="@string/subtitle"
        android:textColor="@color/text_secondary"
        android:textSize="20sp" />

    <TextView
        android:id="@+id/test_button"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginTop="32dp"
        android:background="@drawable/button_bg"
        android:clickable="true"
        android:focusable="true"
        android:paddingLeft="32dp"
        android:paddingTop="14dp"
        android:paddingRight="32dp"
        android:paddingBottom="14dp"
        android:text="@string/test_button"
        android:textColor="@color/text_primary"
        android:textSize="20sp" />
</LinearLayout>
CH_EOF

cat > app/src/main/res/values/colors.xml <<'CH_EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="background">#0B0B0F</color>
    <color name="text_primary">#FFFFFF</color>
    <color name="text_secondary">#9CA3AF</color>
    <color name="accent">#2563FF</color>
    <color name="accent_soft">#332563FF</color>
    <color name="outline">#3A3A44</color>
</resources>
CH_EOF

cat > app/src/main/res/values/strings.xml <<'CH_EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">Cinema Home</string>
    <string name="subtitle">Stage 1: build check</string>
    <string name="test_button">Focus test: press OK</string>
    <string name="ok_works">OK button works</string>
</resources>
CH_EOF

cat > app/src/main/res/values/styles.xml <<'CH_EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.CinemaHome" parent="android:Theme.Material.NoActionBar">
        <item name="android:windowBackground">@color/background</item>
    </style>
</resources>
CH_EOF

cat > app/src/main/res/drawable/button_bg.xml <<'CH_EOF'
<?xml version="1.0" encoding="utf-8"?>
<selector xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:state_focused="true">
        <shape android:shape="rectangle">
            <solid android:color="@color/accent_soft" />
            <stroke android:width="3dp" android:color="@color/accent" />
            <corners android:radius="12dp" />
        </shape>
    </item>
    <item>
        <shape android:shape="rectangle">
            <solid android:color="@android:color/transparent" />
            <stroke android:width="1dp" android:color="@color/outline" />
            <corners android:radius="12dp" />
        </shape>
    </item>
</selector>
CH_EOF

cat > app/src/main/res/drawable/ic_launcher.xml <<'CH_EOF'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="48dp"
    android:height="48dp"
    android:viewportWidth="48"
    android:viewportHeight="48">
    <path
        android:fillColor="#0B0B0F"
        android:pathData="M0,0h48v48h-48z" />
    <path
        android:fillColor="#2563FF"
        android:pathData="M18,14L18,34L35,24z" />
</vector>
CH_EOF

cat > app/src/main/res/drawable/banner.xml <<'CH_EOF'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="320dp"
    android:height="180dp"
    android:viewportWidth="320"
    android:viewportHeight="180">
    <path
        android:fillColor="#0B0B0F"
        android:pathData="M0,0h320v180h-320z" />
    <path
        android:fillColor="#2563FF"
        android:pathData="M140,60L140,120L190,90z" />
</vector>
CH_EOF

# ---------- GitHub Actions workflow ----------
cat > .github/workflows/build.yml <<'CH_EOF'
name: Build debug APK

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Get the code
        uses: actions/checkout@v4

      - name: Install Java 17
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'

      - name: Install Android SDK tools
        uses: android-actions/setup-android@v3

      - name: Install Android platform and build tools
        run: sdkmanager "platforms;android-34" "build-tools;34.0.0"

      - name: Install Gradle 8.7
        uses: gradle/actions/setup-gradle@v4
        with:
          gradle-version: '8.7'

      - name: Build debug APK
        run: gradle assembleDebug --stacktrace

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: CinemaHome-debug-apk
          path: app/build/outputs/apk/debug/*.apk
          if-no-files-found: error
CH_EOF

# ---------- Codespaces configuration (optional, for local builds) ----------
cat > .devcontainer/devcontainer.json <<'CH_EOF'
{
  "name": "Cinema Home",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/java:1": {
      "version": "17",
      "installGradle": true,
      "gradleVersion": "8.7"
    }
  },
  "postCreateCommand": "bash .devcontainer/setup-android-sdk.sh"
}
CH_EOF

cat > .devcontainer/setup-android-sdk.sh <<'CH_EOF'
#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."
if ! command -v unzip > /dev/null; then
  sudo apt-get update && sudo apt-get install -y unzip
fi
SDK="$HOME/android-sdk"
mkdir -p "$SDK/cmdline-tools"
curl -fsSL -o /tmp/cmdtools.zip https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
unzip -q -o /tmp/cmdtools.zip -d "$SDK/cmdline-tools"
rm -rf "$SDK/cmdline-tools/latest"
mv "$SDK/cmdline-tools/cmdline-tools" "$SDK/cmdline-tools/latest"
yes | "$SDK/cmdline-tools/latest/bin/sdkmanager" --licenses > /dev/null || true
"$SDK/cmdline-tools/latest/bin/sdkmanager" "platform-tools" "platforms;android-34" "build-tools;34.0.0"
echo "export ANDROID_HOME=$SDK" >> "$HOME/.bashrc"
echo "sdk.dir=$SDK" > local.properties
echo "Android SDK ready."
CH_EOF

echo ""
echo "Done. All Stage 1 files created."#!/usr/bin/env bash
set -e
echo "Creating Cinema Home Stage 1 files..."

mkdir -p .github/workflows .devcontainer gradle/wrapper
mkdir -p app/src/main/java/com/cinemahome
mkdir -p app/src/main/res/layout app/src/main/res/values app/src/main/res/drawable

# ---------- .gitignore ----------
cat > .gitignore <<'CH_EOF'
.gradle/
build/
local.properties
.idea/
*.iml
captures/
.DS_Store
CH_EOF

# ---------- README ----------
cat > README.md <<'CH_EOF'
# Cinema Home

A minimal, cinematic Android TV launcher (work in progress).

Stage 1: build skeleton with a TV-ready manifest and a focus test button.

## Build in the cloud
Open the Actions tab, run "Build debug APK", then download the
"CinemaHome-debug-apk" artifact from the finished run.

## Versions
Java 17, Gradle 8.7, Android Gradle Plugin 8.5.2, Kotlin 1.9.24,
compileSdk 34, minSdk 21.
CH_EOF

# ---------- Gradle settings ----------
cat > settings.gradle.kts <<'CH_EOF'
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "CinemaHome"
include(":app")
CH_EOF

cat > build.gradle.kts <<'CH_EOF'
plugins {
    id("com.android.application") version "8.5.2" apply false
    id("org.jetbrains.kotlin.android") version "1.9.24" apply false
}
CH_EOF

cat > gradle.properties <<'CH_EOF'
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
android.nonTransitiveRClass=true
kotlin.code.style=official
CH_EOF

cat > gradle/wrapper/gradle-wrapper.properties <<'CH_EOF'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.7-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
CH_EOF

# ---------- App module ----------
cat > app/build.gradle.kts <<'CH_EOF'
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.cinemahome"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.cinemahome"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "0.1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.13.1")
}
CH_EOF

cat > app/src/main/AndroidManifest.xml <<'CH_EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- This app is for Android TV, and a touchscreen is not needed -->
    <uses-feature
        android:name="android.software.leanback"
        android:required="true" />
    <uses-feature
        android:name="android.hardware.touchscreen"
        android:required="false" />

    <application
        android:allowBackup="false"
        android:icon="@drawable/ic_launcher"
        android:banner="@drawable/banner"
        android:label="@string/app_name"
        android:theme="@style/Theme.CinemaHome">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTask"
            android:screenOrientation="landscape">

            <!-- Shows the app in the Android TV app list -->
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LEANBACK_LAUNCHER" />
            </intent-filter>

            <!-- Makes the app eligible to be chosen as the Home screen -->
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.HOME" />
                <category android:name="android.intent.category.DEFAULT" />
            </intent-filter>
        </activity>
    </application>
</manifest>
CH_EOF

cat > app/src/main/java/com/cinemahome/MainActivity.kt <<'CH_EOF'
package com.cinemahome

import android.app.Activity
import android.os.Bundle
import android.widget.TextView
import android.widget.Toast

class MainActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val testButton = findViewById<TextView>(R.id.test_button)
        testButton.setOnClickListener {
            Toast.makeText(this, getString(R.string.ok_works), Toast.LENGTH_SHORT).show()
        }
        testButton.requestFocus()
    }

    // A launcher is the "bottom" screen, so Back should do nothing.
    @Suppress("OVERRIDE_DEPRECATION")
    override fun onBackPressed() {
        // intentionally empty
    }
}
CH_EOF

cat > app/src/main/res/layout/activity_main.xml <<'CH_EOF'
<?xml version="1.0" encoding="utf-8"?>
<!-- Padding of 48dp x 27dp is the standard 5% TV safe margin on a 960x540dp screen -->
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@color/background"
    android:gravity="center"
    android:orientation="vertical"
    android:paddingLeft="48dp"
    android:paddingTop="27dp"
    android:paddingRight="48dp"
    android:paddingBottom="27dp">

    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="@string/app_name"
        android:textColor="@color/text_primary"
        android:textSize="48sp" />

    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginTop="8dp"
        android:text="@string/subtitle"
        android:textColor="@color/text_secondary"
        android:textSize="20sp" />

    <TextView
        android:id="@+id/test_button"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginTop="32dp"
        android:background="@drawable/button_bg"
        android:clickable="true"
        android:focusable="true"
        android:paddingLeft="32dp"
        android:paddingTop="14dp"
        android:paddingRight="32dp"
        android:paddingBottom="14dp"
        android:text="@string/test_button"
        android:textColor="@color/text_primary"
        android:textSize="20sp" />
</LinearLayout>
CH_EOF

cat > app/src/main/res/values/colors.xml <<'CH_EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="background">#0B0B0F</color>
    <color name="text_primary">#FFFFFF</color>
    <color name="text_secondary">#9CA3AF</color>
    <color name="accent">#2563FF</color>
    <color name="accent_soft">#332563FF</color>
    <color name="outline">#3A3A44</color>
</resources>
CH_EOF

cat > app/src/main/res/values/strings.xml <<'CH_EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">Cinema Home</string>
    <string name="subtitle">Stage 1: build check</string>
    <string name="test_button">Focus test: press OK</string>
    <string name="ok_works">OK button works</string>
</resources>
CH_EOF

cat > app/src/main/res/values/styles.xml <<'CH_EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.CinemaHome" parent="android:Theme.Material.NoActionBar">
        <item name="android:windowBackground">@color/background</item>
    </style>
</resources>
CH_EOF

cat > app/src/main/res/drawable/button_bg.xml <<'CH_EOF'
<?xml version="1.0" encoding="utf-8"?>
<selector xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:state_focused="true">
        <shape android:shape="rectangle">
            <solid android:color="@color/accent_soft" />
            <stroke android:width="3dp" android:color="@color/accent" />
            <corners android:radius="12dp" />
        </shape>
    </item>
    <item>
        <shape android:shape="rectangle">
            <solid android:color="@android:color/transparent" />
            <stroke android:width="1dp" android:color="@color/outline" />
            <corners android:radius="12dp" />
        </shape>
    </item>
</selector>
CH_EOF

cat > app/src/main/res/drawable/ic_launcher.xml <<'CH_EOF'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="48dp"
    android:height="48dp"
    android:viewportWidth="48"
    android:viewportHeight="48">
    <path
        android:fillColor="#0B0B0F"
        android:pathData="M0,0h48v48h-48z" />
    <path
        android:fillColor="#2563FF"
        android:pathData="M18,14L18,34L35,24z" />
</vector>
CH_EOF

cat > app/src/main/res/drawable/banner.xml <<'CH_EOF'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="320dp"
    android:height="180dp"
    android:viewportWidth="320"
    android:viewportHeight="180">
    <path
        android:fillColor="#0B0B0F"
        android:pathData="M0,0h320v180h-320z" />
    <path
        android:fillColor="#2563FF"
        android:pathData="M140,60L140,120L190,90z" />
</vector>
CH_EOF

# ---------- GitHub Actions workflow ----------
cat > .github/workflows/build.yml <<'CH_EOF'
name: Build debug APK

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Get the code
        uses: actions/checkout@v4

      - name: Install Java 17
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'

      - name: Install Android SDK tools
        uses: android-actions/setup-android@v3

      - name: Install Android platform and build tools
        run: sdkmanager "platforms;android-34" "build-tools;34.0.0"

      - name: Install Gradle 8.7
        uses: gradle/actions/setup-gradle@v4
        with:
          gradle-version: '8.7'

      - name: Build debug APK
        run: gradle assembleDebug --stacktrace

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: CinemaHome-debug-apk
          path: app/build/outputs/apk/debug/*.apk
          if-no-files-found: error
CH_EOF

# ---------- Codespaces configuration (optional, for local builds) ----------
cat > .devcontainer/devcontainer.json <<'CH_EOF'
{
  "name": "Cinema Home",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/java:1": {
      "version": "17",
      "installGradle": true,
      "gradleVersion": "8.7"
    }
  },
  "postCreateCommand": "bash .devcontainer/setup-android-sdk.sh"
}
CH_EOF

cat > .devcontainer/setup-android-sdk.sh <<'CH_EOF'
#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."
if ! command -v unzip > /dev/null; then
  sudo apt-get update && sudo apt-get install -y unzip
fi
SDK="$HOME/android-sdk"
mkdir -p "$SDK/cmdline-tools"
curl -fsSL -o /tmp/cmdtools.zip https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
unzip -q -o /tmp/cmdtools.zip -d "$SDK/cmdline-tools"
rm -rf "$SDK/cmdline-tools/latest"
mv "$SDK/cmdline-tools/cmdline-tools" "$SDK/cmdline-tools/latest"
yes | "$SDK/cmdline-tools/latest/bin/sdkmanager" --licenses > /dev/null || true
"$SDK/cmdline-tools/latest/bin/sdkmanager" "platform-tools" "platforms;android-34" "build-tools;34.0.0"
echo "export ANDROID_HOME=$SDK" >> "$HOME/.bashrc"
echo "sdk.dir=$SDK" > local.properties
echo "Android SDK ready."
CH_EOF

echo ""
echo "Done. All Stage 1 files created."#!/usr/bin/env bash
set -e
echo "Creating Cinema Home Stage 1 files..."

mkdir -p .github/workflows .devcontainer gradle/wrapper
mkdir -p app/src/main/java/com/cinemahome
mkdir -p app/src/main/res/layout app/src/main/res/values app/src/main/res/drawable

# ---------- .gitignore ----------
cat > .gitignore <<'CH_EOF'
.gradle/
build/
local.properties
.idea/
*.iml
captures/
.DS_Store
CH_EOF

# ---------- README ----------
cat > README.md <<'CH_EOF'
# Cinema Home

A minimal, cinematic Android TV launcher (work in progress).

Stage 1: build skeleton with a TV-ready manifest and a focus test button.

## Build in the cloud
Open the Actions tab, run "Build debug APK", then download the
"CinemaHome-debug-apk" artifact from the finished run.

## Versions
Java 17, Gradle 8.7, Android Gradle Plugin 8.5.2, Kotlin 1.9.24,
compileSdk 34, minSdk 21.
CH_EOF

# ---------- Gradle settings ----------
cat > settings.gradle.kts <<'CH_EOF'
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "CinemaHome"
include(":app")
CH_EOF

cat > build.gradle.kts <<'CH_EOF'
plugins {
    id("com.android.application") version "8.5.2" apply false
    id("org.jetbrains.kotlin.android") version "1.9.24" apply false
}
CH_EOF

cat > gradle.properties <<'CH_EOF'
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
android.nonTransitiveRClass=true
kotlin.code.style=official
CH_EOF

cat > gradle/wrapper/gradle-wrapper.properties <<'CH_EOF'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.7-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
CH_EOF

# ---------- App module ----------
cat > app/build.gradle.kts <<'CH_EOF'
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.cinemahome"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.cinemahome"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "0.1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.13.1")
}
CH_EOF

cat > app/src/main/AndroidManifest.xml <<'CH_EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- This app is for Android TV, and a touchscreen is not needed -->
    <uses-feature
        android:name="android.software.leanback"
        android:required="true" />
    <uses-feature
        android:name="android.hardware.touchscreen"
        android:required="false" />

    <application
        android:allowBackup="false"
        android:icon="@drawable/ic_launcher"
        android:banner="@drawable/banner"
        android:label="@string/app_name"
        android:theme="@style/Theme.CinemaHome">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTask"
            android:screenOrientation="landscape">

            <!-- Shows the app in the Android TV app list -->
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LEANBACK_LAUNCHER" />
            </intent-filter>

            <!-- Makes the app eligible to be chosen as the Home screen -->
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.HOME" />
                <category android:name="android.intent.category.DEFAULT" />
            </intent-filter>
        </activity>
    </application>
</manifest>
CH_EOF

cat > app/src/main/java/com/cinemahome/MainActivity.kt <<'CH_EOF'
package com.cinemahome

import android.app.Activity
import android.os.Bundle
import android.widget.TextView
import android.widget.Toast

class MainActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val testButton = findViewById<TextView>(R.id.test_button)
        testButton.setOnClickListener {
            Toast.makeText(this, getString(R.string.ok_works), Toast.LENGTH_SHORT).show()
        }
        testButton.requestFocus()
    }

    // A launcher is the "bottom" screen, so Back should do nothing.
    @Suppress("OVERRIDE_DEPRECATION")
    override fun onBackPressed() {
        // intentionally empty
    }
}
CH_EOF

cat > app/src/main/res/layout/activity_main.xml <<'CH_EOF'
<?xml version="1.0" encoding="utf-8"?>
<!-- Padding of 48dp x 27dp is the standard 5% TV safe margin on a 960x540dp screen -->
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@color/background"
    android:gravity="center"
    android:orientation="vertical"
    android:paddingLeft="48dp"
    android:paddingTop="27dp"
    android:paddingRight="48dp"
    android:paddingBottom="27dp">

    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="@string/app_name"
        android:textColor="@color/text_primary"
        android:textSize="48sp" />

    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginTop="8dp"
        android:text="@string/subtitle"
        android:textColor="@color/text_secondary"
        android:textSize="20sp" />

    <TextView
        android:id="@+id/test_button"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginTop="32dp"
        android:background="@drawable/button_bg"
        android:clickable="true"
        android:focusable="true"
        android:paddingLeft="32dp"
        android:paddingTop="14dp"
        android:paddingRight="32dp"
        android:paddingBottom="14dp"
        android:text="@string/test_button"
        android:textColor="@color/text_primary"
        android:textSize="20sp" />
</LinearLayout>
CH_EOF

cat > app/src/main/res/values/colors.xml <<'CH_EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="background">#0B0B0F</color>
    <color name="text_primary">#FFFFFF</color>
    <color name="text_secondary">#9CA3AF</color>
    <color name="accent">#2563FF</color>
    <color name="accent_soft">#332563FF</color>
    <color name="outline">#3A3A44</color>
</resources>
CH_EOF

cat > app/src/main/res/values/strings.xml <<'CH_EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">Cinema Home</string>
    <string name="subtitle">Stage 1: build check</string>
    <string name="test_button">Focus test: press OK</string>
    <string name="ok_works">OK button works</string>
</resources>
CH_EOF

cat > app/src/main/res/values/styles.xml <<'CH_EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.CinemaHome" parent="android:Theme.Material.NoActionBar">
        <item name="android:windowBackground">@color/background</item>
    </style>
</resources>
CH_EOF

cat > app/src/main/res/drawable/button_bg.xml <<'CH_EOF'
<?xml version="1.0" encoding="utf-8"?>
<selector xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:state_focused="true">
        <shape android:shape="rectangle">
            <solid android:color="@color/accent_soft" />
            <stroke android:width="3dp" android:color="@color/accent" />
            <corners android:radius="12dp" />
        </shape>
    </item>
    <item>
        <shape android:shape="rectangle">
            <solid android:color="@android:color/transparent" />
            <stroke android:width="1dp" android:color="@color/outline" />
            <corners android:radius="12dp" />
        </shape>
    </item>
</selector>
CH_EOF

cat > app/src/main/res/drawable/ic_launcher.xml <<'CH_EOF'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="48dp"
    android:height="48dp"
    android:viewportWidth="48"
    android:viewportHeight="48">
    <path
        android:fillColor="#0B0B0F"
        android:pathData="M0,0h48v48h-48z" />
    <path
        android:fillColor="#2563FF"
        android:pathData="M18,14L18,34L35,24z" />
</vector>
CH_EOF

cat > app/src/main/res/drawable/banner.xml <<'CH_EOF'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="320dp"
    android:height="180dp"
    android:viewportWidth="320"
    android:viewportHeight="180">
    <path
        android:fillColor="#0B0B0F"
        android:pathData="M0,0h320v180h-320z" />
    <path
        android:fillColor="#2563FF"
        android:pathData="M140,60L140,120L190,90z" />
</vector>
CH_EOF

# ---------- GitHub Actions workflow ----------
cat > .github/workflows/build.yml <<'CH_EOF'
name: Build debug APK

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Get the code
        uses: actions/checkout@v4

      - name: Install Java 17
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'

      - name: Install Android SDK tools
        uses: android-actions/setup-android@v3

      - name: Install Android platform and build tools
        run: sdkmanager "platforms;android-34" "build-tools;34.0.0"

      - name: Install Gradle 8.7
        uses: gradle/actions/setup-gradle@v4
        with:
          gradle-version: '8.7'

      - name: Build debug APK
        run: gradle assembleDebug --stacktrace

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: CinemaHome-debug-apk
          path: app/build/outputs/apk/debug/*.apk
          if-no-files-found: error
CH_EOF

# ---------- Codespaces configuration (optional, for local builds) ----------
cat > .devcontainer/devcontainer.json <<'CH_EOF'
{
  "name": "Cinema Home",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/java:1": {
      "version": "17",
      "installGradle": true,
      "gradleVersion": "8.7"
    }
  },
  "postCreateCommand": "bash .devcontainer/setup-android-sdk.sh"
}
CH_EOF

cat > .devcontainer/setup-android-sdk.sh <<'CH_EOF'
#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."
if ! command -v unzip > /dev/null; then
  sudo apt-get update && sudo apt-get install -y unzip
fi
SDK="$HOME/android-sdk"
mkdir -p "$SDK/cmdline-tools"
curl -fsSL -o /tmp/cmdtools.zip https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
unzip -q -o /tmp/cmdtools.zip -d "$SDK/cmdline-tools"
rm -rf "$SDK/cmdline-tools/latest"
mv "$SDK/cmdline-tools/cmdline-tools" "$SDK/cmdline-tools/latest"
yes | "$SDK/cmdline-tools/latest/bin/sdkmanager" --licenses > /dev/null || true
"$SDK/cmdline-tools/latest/bin/sdkmanager" "platform-tools" "platforms;android-34" "build-tools;34.0.0"
echo "export ANDROID_HOME=$SDK" >> "$HOME/.bashrc"
echo "sdk.dir=$SDK" > local.properties
echo "Android SDK ready."
CH_EOF

echo ""
echo "Done. All Stage 1 files created."
