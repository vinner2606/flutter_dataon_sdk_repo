import 'package:pwc/listeners/Consumer.dart';
import 'package:pwc/response/Response.dart';
import 'package:pwc/response/commands/Command.dart';
import 'package:pwc/response/receiver/ResponseCommandReciever.dart';

class HandleResponseCommand extends Command {
  ResponseCommandReciever receiver;
  Consumer<List<Response>> consumer;

  HandleResponseCommand(this.receiver, this.consumer);

  @override
  void execute() async {
    var responseList = await receiver.handleResponse();
    consumer?.accept(responseList);
  }
}
