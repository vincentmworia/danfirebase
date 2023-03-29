import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const url =
      'https://cbes-desktop-default-rtdb.europe-west1.firebasedatabase.app/cbes_data/thermal_energy.json';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final myController = TextEditingController();
  final myStream = StreamController();
 late Timer timer  ;

  // http.get(Uri.parse(HomeScreen.url))
  @override
  void initState() {
    super.initState();
    myStream.sink.add("Data Initialization");
    timer= Timer.periodic(const Duration(seconds: 3), (timer) async {
   final resp = await  http.get(Uri.parse(HomeScreen.url));
      final respData = json.decode(resp.body) as String ;

      print(respData);
      myStream.sink.add(respData);
    });

  }

  @override
  void dispose() {
    super.dispose();
    myController.dispose();
    myStream.close();
    timer.cancel();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 50,
              child: StreamBuilder(
                  stream: myStream.stream,
                  builder: (context, snap) {
                    return Text(snap.data);
                  }),

            ),
            TextField(controller: myController,),
            ElevatedButton(
                onPressed: () async {

                  print('Sending ${myController.text}');
                  await http.put(
                      Uri.parse(
                          'https://cbes-desktop-default-rtdb.europe-west1.firebasedatabase.app/cbes_data/thermal_energy.json'),
                      body: json.encode(myController.text));
                  print('done');
                  myController.text="";

                },
                child: Text("Send"))
          ],
        ),
      ),
    ));
  }
}
