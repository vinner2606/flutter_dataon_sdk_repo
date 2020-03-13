import 'package:pwc/request/Request.dart';
import 'package:pwc/response/commands/Command.dart';
import 'package:pwc/response/receiver/ResponseCommandReciever.dart';

class MultipleSessionCommand extends Command {
  ResponseCommandReciever receiver;
  Request request;

  MultipleSessionCommand(this.receiver, this.request);

  @override
  void execute() {
    receiver.killMultipleSession(request);
  }
}
