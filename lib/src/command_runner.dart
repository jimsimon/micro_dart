part of micro_dart;

class MicroDartCommandRunner extends CommandRunner {

  MicroDart bundleManager;
  MicroDartCommandRunner(this.bundleManager) : super("micro_dart", "Dart microservices framework") {
      addCommand(new StartCommand(bundleManager));
      addCommand(new StopCommand(bundleManager));
      addCommand(new ExitCommand(bundleManager));
  }

  String get invocation => "<command> [arguments]";

  String get usage {
    String usage = super.usage;
    return usage.replaceFirst("$executableName help <command>", "help <command>");
  }

}