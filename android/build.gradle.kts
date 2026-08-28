allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Some plugins (e.g. agora_rtc_engine) fall back to an outdated compileSdkVersion
// unless the root project overrides it via ext — bumps them in line with app/build.gradle.kts.
ext["compileSdkVersion"] = 36

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}