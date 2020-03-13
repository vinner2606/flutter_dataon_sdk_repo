import 'package:pwc/response/commands/Command.dart';
import 'package:pwc/response/receiver/ResponseCommandReciever.dart';

class LogoutCommand extends Command {
  ResponseCommandReciever receiver;

  LogoutCommand(this.receiver);

  @override
  void execute() {
    receiver.logoutUser();
  }
}
