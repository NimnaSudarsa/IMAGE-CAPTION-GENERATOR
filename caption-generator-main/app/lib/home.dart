import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audiofileplayer/audiofileplayer.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:visual/camera.dart';
import 'package:http/http.dart' as http;

String serverUrl = "";
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {

  Audio? audio;
  Box box = Hive.box('app');
  String caption = "";

  @override
  void initState() {
    super.initState();

    try {
      serverUrl = box.get('server_url');
    }catch(err) {
      debugPrint("Error fetching server url");
    }
    serverUrl ??= "";

  }

  Future<void> sendRequest(String base64Image) async {
    final uri = Uri.parse('$serverUrl/api/generate');

    debugPrint('Make HTTP request to server (${uri.toString()})');

    // post request
    var response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'image': base64Image,
          'extension': 'jpg'
        }));
    var decoded = json.decode(response.body);
    debugPrint('Got response from server with body $decoded');

    audio = Audio.loadFromRemoteUrl('$serverUrl/audio/${decoded['audio_id']}');
    audio?.play();
    debugPrint('Played successfully!');

    setState(() {
      try {
        bool isCaptionEnabled = box.get('isCaptionEnabled');
        if(isCaptionEnabled){
          caption = decoded['caption'];
        }
      }catch(err){
        debugPrint('Error with isCaptionEnabled settings');
      }
    });
  }


  void cameraBtnClicked() {
    debugPrint('camera clicked');
    showDialog(context: context, builder: (context) {
      return const Center(
          child: CircularProgressIndicator()
      );
    });
    controller.takePicture().then((XFile? file) async {
      if(file != null) {
        debugPrint('File saved to the path ${file.path}');

        File imageFile = File(file.path);

        Uint8List imageBytes = imageFile.readAsBytesSync();
        String base64 = base64Encode(imageBytes);

        debugPrint("Base 64 encode is $base64");

        await sendRequest(base64);

        Navigator.of(context).pop();

      }
    }).catchError((error) {
      print(error);
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.green,
        child: Stack(
          children: [
            const Positioned.fill(
                child: CameraApp()
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 50),
                  width: double.infinity,
                  alignment: Alignment.topLeft,
                  child: Text(caption, style: const TextStyle(
                    fontSize: 20,
                    backgroundColor: Colors.white,
                    fontWeight: FontWeight.bold
                  ),),
                )
              ],
            ),
            Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(bottom: 20),
                      child: FloatingActionButton(
                        onPressed: cameraBtnClicked,
                        backgroundColor: const Color.fromRGBO(31, 31, 31, 1),
                        child: const Icon(Icons.circle, color: Color.fromRGBO(66, 66, 66, 1), size: 40,),
                      )
                  )
                ]
            )
          ],
        )
    );
  }
}
