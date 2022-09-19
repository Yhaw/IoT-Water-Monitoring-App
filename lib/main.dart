import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:watwe/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

enum Status {
  Pumping,
  TurnedOff,
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Stream<QuerySnapshot> _DataStream = FirebaseFirestore.instance
      .collection('Sensors')
      .snapshots(includeMetadataChanges: true);

  CollectionReference pushs = FirebaseFirestore.instance.collection('Sensors');

  late bool isTurnOn = false;
  late String Tit = "OFF";

  void isChanged(value) {
    setState(() {
      isTurnOn = value;

      if (isTurnOn == true) {
        Tit = "ON";
      } else {
        Tit = "OFF";
      }
    });
  }

  Future<void> updateData() {
    return pushs
        .doc('Data')
        .update({'status': Tit})
        .then((value) => print("Dara Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 250, 250, 250),
        appBar: AppBar(
          toolbarHeight: 80,
          title: Text(
            "Smart Water Level Monitor",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 82, 81, 81),
            ),
          ),
          centerTitle: true,
          backgroundColor: Color.fromARGB(255, 135, 214, 245),
          elevation: 2,
          titleTextStyle: const TextStyle(
            color: Colors.white,
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _DataStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(
                color: Colors.black,
                semanticsValue: "Loading ...",
              ));
            } else {
              return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  return Container(
                      child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 0.0),
                        child: SizedBox(
                          width: 700,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 0.0, top: 30, right: 100),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Image.asset('images/temperature.png',
                                      width: 35, height: 35),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: Text(
                                    "Water Temperature: ",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal,
                                      color: Color.fromARGB(255, 41, 40, 40),
                                    ),
                                  ),
                                ),
                                Text(
                                  data['Temperature'].toString(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal,
                                    color: Color.fromARGB(255, 77, 113, 230),
                                  ),
                                ),
                                Text(
                                  "°c",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal,
                                    color: Color.fromARGB(255, 41, 40, 40),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 0.0, top: 20, right: 144),
                        child: SizedBox(
                          height: 40,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 0.0),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Image.asset('images/pump.png',
                                      width: 35, height: 35),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: Text(
                                    "Pump Status: ",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal,
                                      color: Color.fromARGB(255, 58, 56, 56),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 0),
                                  child: Text(
                                    '$Tit',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal,
                                      color: Color.fromARGB(255, 77, 113, 230),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: SizedBox(
                          height: 400,
                          width: 180,
                          child: LiquidLinearProgressIndicator(
                            value: (data['Level'] / 100.00),
                            valueColor: const AlwaysStoppedAnimation(
                                Color.fromARGB(255, 135, 214, 245)),
                            center: Text(
                              data['Level'].toString() + "%",
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.normal,
                                color: Color.fromARGB(255, 131, 110, 89),
                              ),
                            ),
                            backgroundColor: Color.fromARGB(255, 10, 7, 7),
                            direction: Axis.vertical,
                            borderRadius: 20,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 35.0),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // Respond to button press
                                  isChanged(true);
                                  updateData();
                                },
                                icon: Image.asset('images/pump.png',
                                    width: 30, height: 30),
                                label: Text("PUMP ON"),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 35.0),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // Respond to button press
                                  isChanged(false);
                                  updateData();
                                },
                                icon: Image.asset('images/pump.png',
                                    width: 30, height: 30),
                                label: Text("PUMP OFF"),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ));
                }).toList(),
              );
            }
          },
        ));
  }
}
