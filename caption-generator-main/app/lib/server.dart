import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;


bool serverLive = false;
String serverUrl = "";
class ServerPage extends StatefulWidget {
  const ServerPage({Key? key}) : super(key: key);

  @override
  State<ServerPage> createState() => _ServerPageState();
}

class _ServerPageState extends State<ServerPage> {

  Box box = Hive.box('app');

  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();

    try {
      serverUrl = box.get('server_url');
    }catch(err) {
      debugPrint("Error fetching server url");
    }
    serverUrl ??= "";

    controller.text = serverUrl;

    connectToServer();
 }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> connectToServer() async {

    showDialog(context: context, builder: (context) {
      return const Center(
        child: CircularProgressIndicator()
      );
    });

    Server server = Server();
    serverLive = await server.getServerStatus(controller.text);
    setState((){});

    Navigator.of(context).pop();
  }

  Future<String?> updateDialog() {
    return showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Connect to server'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter text'),
            controller: controller,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(controller.text);
                connectToServer();
              },
              child: const Text('Connect'),
            )
          ],
        )
    );
  }

  Widget renderPage(serverLive) {
    if(serverLive) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/server-connected.svg'),
            const SizedBox(height: 10),
            const Text('Server Connection Established',
              style: TextStyle(
                  color: Color.fromRGBO(113, 195, 134, 1),
                  fontSize: 23,
                  fontWeight: FontWeight.bold
              ),),
            const SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      debugPrint('Update server clicked');
                      final server = await updateDialog();
                      debugPrint('Server updated to $server');
                      box.put('server_url', server);
                    },
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.fromLTRB(30, 12, 30, 12),
                        backgroundColor: const Color.fromRGBO(103, 58, 183, 1)
                    ),
                    child: const Text(
                      'Update Server',
                      style: TextStyle(
                          fontSize: 18
                      ),
                    )
                ),
              ],
            ),
          ],
        ),
      );
    }else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/server-disconnected.svg'),
            const SizedBox(height: 10),
            const Text('Server Connection Lost',
              style: TextStyle(
                  color: Color.fromRGBO(237, 113, 97, 1),
                  fontSize: 23,
                  fontWeight: FontWeight.bold
              ),),
            const SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    debugPrint('Retry clicked');
                    connectToServer();
                  },
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.fromLTRB(30, 12, 30, 12),
                      backgroundColor: const Color.fromRGBO(103, 58, 183, 1)
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                        fontSize: 18
                    ),
                  ),

                ),
                const SizedBox(width: 15,),
                ElevatedButton(
                    onPressed: () async {
                      debugPrint('Update server clicked');
                      final server = await updateDialog();
                      debugPrint('Server updated to $server');
                      box.put('server_url', server);
                    },
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.fromLTRB(30, 12, 30, 12),
                        backgroundColor: const Color.fromRGBO(103, 58, 183, 1)
                    ),
                    child: const Text(
                      'Update Server',
                      style: TextStyle(
                          fontSize: 18
                      ),
                    )
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color.fromRGBO(31, 31, 31, 1),
        child: renderPage(serverLive)
      // child: SvgPicture.asset('assets/server-disconnected.svg'),
    );
  }
}

class Server {



  Future<bool> getServerStatus(String server) async {

    if(server == '') {
      return false;
    }

    Uri uri = Uri.parse('$server/live');
    debugPrint('Make HTTP request to server (${uri.toString()})');

    http.Response response;
    try {
      response = await http.get(uri);
      return response.statusCode == 200;
    }catch(err) {
      if (kDebugMode) {
        print(err);
        return false;
      }
    }

    return true;
  }
}