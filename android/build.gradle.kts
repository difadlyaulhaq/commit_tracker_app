allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Ganti lokasi build directory HANYA untuk root project
val newBuildDir = file("${rootDir.parentFile}/build")
buildDir = newBuildDir

// Terapkan buildDir yang baru ke semua subproject lokal
subprojects {
    // Filter hanya subproject lokal, hindari yang dari .pub-cache
    if (project.projectDir.absolutePath.startsWith(rootDir.absolutePath)) {
        buildDir = File(newBuildDir, project.name)
    }

    // Pastikan subproject evaluasi dependensinya setelah `:app`
    project.evaluationDependsOn(":app")
}

// Task clean
tasks.register<Delete>("clean") {
    delete(buildDir)
}
