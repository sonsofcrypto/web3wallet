import org.gradle.api.DefaultTask
import org.gradle.api.tasks.Input
import org.gradle.api.tasks.InputFile
import org.gradle.api.tasks.TaskAction


open class IosSimulatorTestsTask: DefaultTask() {

    @InputFile
    val testExecutable = project.objects.fileProperty()

    @Input
    val simulatorId = project.objects.property(String::class.java)

    @TaskAction
    fun runIosTests() {
        val device = simulatorId.get()
        try {
            project.exec { commandLine("xcrun", "simctl", "boot", device) }
            println(device)
            println(testExecutable.get())
            val spawnResult = project.exec { commandLine("xcrun", "simctl", "spawn", device, testExecutable.get()) }
            spawnResult.assertNormalExitValue()
        } catch (err: Throwable) {
            println(err)
        } finally {
            project.exec { commandLine("xcrun", "simctl", "shutdown", device) }
        }
    }
}