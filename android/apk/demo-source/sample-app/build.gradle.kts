import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.plugin.compose")
}

val localProperties = Properties().apply {
    val propertiesFile = rootProject.file("local.properties")
    if (propertiesFile.isFile) {
        propertiesFile.inputStream().use(::load)
    }
}

fun localPropertyOrEnv(propertyName: String, envName: String): String =
    localProperties.getProperty(propertyName) ?: System.getenv(envName).orEmpty()

fun String.asBuildConfigString(): String =
    "\"" + replace("\\", "\\\\").replace("\"", "\\\"") + "\""

android {
    namespace = "com.salesmartly.chatwidget.sample"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.salesmartly.chatwidget.sample"
        minSdk = 23
        targetSdk = 36
        versionCode = 1
        versionName = "1.0.0"
        buildConfigField(
            "String",
            "SALESMARTLY_LICENSE",
            localPropertyOrEnv("salesmartly.license", "SALESMARTLY_LICENSE").asBuildConfigString(),
        )
        buildConfigField(
            "String",
            "SALESMARTLY_SCRIPT_URL",
            localPropertyOrEnv("salesmartly.scriptUrl", "SALESMARTLY_SCRIPT_URL").asBuildConfigString(),
        )
        buildConfigField(
            "String",
            "SALESMARTLY_WIDGET_HOST",
            localPropertyOrEnv("salesmartly.widgetHost", "SALESMARTLY_WIDGET_HOST").asBuildConfigString(),
        )
    }

    buildFeatures {
        compose = true
        buildConfig = true
    }
}

dependencies {
    implementation(files(rootProject.file("../../sdk/salesmartly-chatwidget-sdk-v0.1.0.aar")))
    implementation(platform("androidx.compose:compose-bom:2026.03.01"))
    implementation(platform("com.squareup.retrofit2:retrofit-bom:3.0.0"))
    implementation("androidx.activity:activity-compose:1.13.0")
    implementation("androidx.compose.foundation:foundation")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.runtime:runtime")
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.datastore:datastore-preferences:1.2.1")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.10.0")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.10.0")
    implementation("androidx.room:room-runtime:2.8.4")
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
    implementation("com.squareup.retrofit2:converter-kotlinx-serialization")
    implementation("com.squareup.retrofit2:retrofit")
    implementation("io.socket:socket.io-client:2.1.2") {
        exclude(group = "org.json", module = "json")
    }
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.10.2")
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.10.0")
    debugImplementation("androidx.compose.ui:ui-tooling")
}
