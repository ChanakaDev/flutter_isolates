// ignore_for_file: avoid_print, non_constant_identifier_names

import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';

void main() {
  //? Calling the method to create the isolate
  createIsolate();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FLUTTER ISOLATES',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: false, //? Using or not Material 3 style
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FLUTTER ISOLATES"),
        centerTitle: true,
      ),
      body: const Column(
        children: [],
      ),
    );
  }
}

/// No return type
Future createIsolate() async {
  //? Ports
  /// Where I listen to the message from Chanaka's port
  ReceivePort mainReceivePort = ReceivePort();

  /// Spawn an isolate, passing main receivePort sendPort
  Isolate chanakaIsolate = await Isolate.spawn<SendPort>(
    heavyComputationTask, // Method
    mainReceivePort.sendPort, // Parameters for that method
  );

  SendPort? ChanakaSendPort;

  //? Listners
  /// Added a listner to the receivePort to get the messages coming from sendPort
  StreamSubscription mainReceivePortListner = mainReceivePort.listen((message) {
    if (message is SendPort) {
      /// Chanaka sends a sendPort for main to enable main to send him a message
      /// via his sendPort.
      /// Main receieve Chanaka's sendPort via main receivePort
      ChanakaSendPort = message;

      //? We can pass any data through ports
      /// Main send Chanaka a message using ChanakaSendPort. Main send him a list,
      /// which include main message, perfer type of coffee
      ChanakaSendPort!.send([
        "Chinease Girl",
        "Hi Chanaka!! I'm Chinease Girl. I love you <3",
      ]);
    } else if (message is String) {
      /// Main get Chanaka's presponse
      print("=============================");
      print("Chanaka's response: $message");
      print("=============================");
    }
  });

  //? Calcelling the listners and killing tthe isolate
  Future.delayed(const Duration(seconds: 2), () {
    mainReceivePortListner.cancel();
    chanakaIsolate.kill();
  });
}

void heavyComputationTask(SendPort mainSendPort) async {
  //? Ports
  /// Set up a receiver port for Chanaka
  ReceivePort ChanakaReceivePort = ReceivePort();

  /// Send Chanaka receivePort sendPort via mainSendPort
  mainSendPort.send(ChanakaReceivePort.sendPort);

  //? Listners
  /// Listen to messages sent to Chanaka's receive port
  await for (var message in ChanakaReceivePort) {
    if (message is List) {
      final herName = message[0];
      final herMessage = message[1];

      /// Logs
      print("*******************************");
      print("Inside the background isolate");
      print("Messages from the main isolate");
      print("herName: $herName");
      print("herMessage: $herMessage");
      print("*******************************");

      /// Send Chanaka's response
      mainSendPort.send("I received your message $herName. let's be friends ^^");
    }
  }
}
