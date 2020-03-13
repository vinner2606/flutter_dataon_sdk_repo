
import 'package:pwc/response/commands/Command.dart';
import 'package:pwc/response/receiver/ResponseCommandReciever.dart';

class AuthenticateCommand extends Command {

  ResponseCommandReciever reciever;


  AuthenticateCommand(this.reciever);

  @override
  void execute() {
    reciever.authenticateUser();
  }


}