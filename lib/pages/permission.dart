
import 'package:permission_handler/permission_handler.dart';

Future<void> permission()async{
  await Permission.location.request();
}