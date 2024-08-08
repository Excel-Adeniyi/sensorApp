import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final platform = const MethodChannel('com.example.usb/method');
  final pressureChannel = const EventChannel('com.example.usb/pressure');

  String _sensorReading = "unknown";
  double _pressureReading = 0;
  late StreamSubscription pressureSubscription;
  Future<void> getUsbName() async {
    try {
      var nameUsb = await platform.invokeMethod('availableUsb');

      setState(() {
        _sensorReading = nameUsb.toString();
      });
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  _startReading() {
    pressureSubscription =
        pressureChannel.receiveBroadcastStream().listen((event) {
      setState(() {
        _pressureReading = event;
      });
    });
  }

  _stopReading() {
    setState(() {
      _pressureReading = 0;
    });
    pressureSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_sensorReading),
              ElevatedButton(
                  onPressed: () {
                    getUsbName();
                  },
                  child: const Text('Fetch USB')),
              const SizedBox(
                height: 20,
              ),
              if (_pressureReading != 0)
                Text('Pressure Reading: $_pressureReading'),
              if (_sensorReading == 'true' && _pressureReading == 0)
                ElevatedButton(
                    onPressed: () {
                      _startReading();
                    },
                    child: const Text('Start reading')),
              if (_pressureReading != 0)
                ElevatedButton(
                    onPressed: () {
                      _stopReading();
                    },
                    child: const Text('Stop Reading'))
            ],
          ),
        ),
      ),
    );
  }
}
