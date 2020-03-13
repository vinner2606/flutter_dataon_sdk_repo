import 'package:pwc/listeners/PWCCallback.dart';
import 'package:pwc/response/commands/Command.dart';
import 'package:pwc/response/receiver/ResponseCommandReciever.dart';

import '../Response.dart';

class RegisterCommand extends Command {
  ResponseCommandReciever receiver;
  Function afterRegistration;
  PWCCallback<List<Response>> mCallback;

  RegisterCommand(this.receiver, this.afterRegistration, this.mCallback);

  @override
  void execute() {
    receiver.registerUser(afterRegistration, mCallback);
  }
}
