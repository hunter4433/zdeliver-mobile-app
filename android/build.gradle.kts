allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    // Add the dependency for the Google services Gradle plugin
    // id("com.google.gms.google-services") version "4.4.2" apply false
}

// Define NDK path explicitly
val ndkPath = "/Users/tihom4537/Library/Android/sdk/ndk/26.1.10909125" // Use a version that's installed and working

// Build directory relocation (if needed)
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // Apply NDK configuration to all Android projects
    afterEvaluate {
        if (plugins.hasPlugin("com.android.application") ||
                plugins.hasPlugin("com.android.library")) {

            extensions.findByType<com.android.build.gradle.BaseExtension>()?.apply {
                ndkVersion = "26.1.10909125" // Use installed version
                // Or use absolute path if version approach doesn't work
                // ndkPath = ndkPath
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}