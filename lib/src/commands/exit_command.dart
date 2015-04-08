part of micro_dart;

class ExitCommand extends Command {

  MicroDart bundleManager;
  ExitCommand(this.bundleManager);

  String get name => "exit";
  String get description => "Stops all bundles";
  void run() {
    new StopCommand(bundleManager).run();
    print("Shutting down...");
    exit(0);
  }
}