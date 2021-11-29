import 'package:blue/screens/menu/menu.dart';
import 'package:blue/screens/shared_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';

class BluetoothApp extends StatefulWidget {
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  //1. Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //2. Get the instance of the Bluetooth
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  // Track the Bluetooth connection with the remote device
  late BluetoothConnection connection;

  late int _deviceState;

  bool isDisconnecting = false;

  Map<String, Color> colors = {
    'onBorderColor': Colors.green,
    'offBorderColor': Colors.red,
    'neutralBorderColor': Colors.transparent,
    'onTextColor': Colors.green,
    'offTextColor': Colors.red,
    'neutralTextColor': Colors.blue,
  };

  // To track whether the device is still connected to Bluetooth
  bool get isConnected => connection != null && connection.isConnected;

  // Define some variables, which will be required later
  List<BluetoothDevice> _devicesList = [];
  late BluetoothDevice _device;
  bool _connected = false;
  bool _isButtonUnavailable = false;

  var luciana = [];

  //----------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();

    //a. Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    _deviceState = 0; // neutral

    //b. If the bluetooth of the device is not enabled then request permission to turn on bluetooth as the app starts up
    enableBluetooth();

    //c. Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        if (_bluetoothState == BluetoothState.STATE_OFF) {
          _isButtonUnavailable = true;
        }
        getPairedDevices();
      });
    });
  }
  //----------------------------------------------------------------------------
  @override
  void dispose() {
    //a. Avoid memory leak and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      // connection = null;
    }

    super.dispose();
  }

  //----------------------------------------------------------------------------
  // Request Bluetooth permission from the user
  Future<bool> enableBluetooth() async {
    //a. Retrieving the current Bluetooth state
    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    //b. If the bluetooth is off, then turn it on first and then retrieve the devices that are paired.
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return true;
    } else {
      await getPairedDevices();
    }
    return false;
  }
  //----------------------------------------------------------------------------

  // For retrieving and storing the paired devices
  // in a list.
  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing the list outside this class
    setState(() {
      _devicesList = devices;
    });
  }

  //----------------------------------------------------------------------------
  // USER INTERFACE
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // key: _scaffoldKey,
      //----------------------------------------------------------------------
      appBar: AppBar(
        backgroundColor: Color(0xFFffffff),
        iconTheme: IconThemeData(color: Color(0xFF005f81)),
        elevation: 2.0,
        toolbarHeight: 68.0,
        titleSpacing: 0,

        title: Image.asset("assets/images/A2EI.png", height: 20.0),
        actions: <Widget>[
          IconButton(onPressed: (){
            // On pressing the menu button => the menu screen is served

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SharedFiles()),
            );
          }, icon: Icon(Icons.folder_open_rounded, size: 28)),
          SizedBox(width: 10,),
          IconButton(onPressed: (){
            // On pressing the menu button => the menu screen is served

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Menu()),
            );
          }, icon: Icon(Icons.menu_rounded, size: 28)),
          SizedBox(width: 20,),

          // FlatButton.icon(
          //   icon: Icon(
          //     Icons.refresh,
          //     color: Colors.white,
          //   ),
          //   label: Text(
          //     "Refresh",
          //     style: TextStyle(
          //       color: Colors.white,
          //     ),
          //   ),
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.circular(30),
          //   ),
          //   splashColor: Colors.deepPurple,
          //   onPressed: () async {
          //     // So, that when new devices are paired
          //     // while the app is running, user can refresh
          //     // the paired devices list.
          //     await getPairedDevices().then((_) {
          //       show('Device list refreshed');
          //     });
          //   },
          // ),
        ],
      ),
      //----------------------------------------------------------------------
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),

        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            //----------------------------------------------------------------
            Visibility(
              visible: _isButtonUnavailable &&
                  _bluetoothState == BluetoothState.STATE_ON,
              child: LinearProgressIndicator(
                backgroundColor: Color(0xFF005f81),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0097ce)),
              ),
            ),
            //----------------------------------------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.start,

              children: [
                Expanded(
                  child: Text('Enable Bluetooth'),
                ),
                Switch(
                  activeColor: Color(0xFF00b7cc1),
                  value: _bluetoothState.isEnabled,
                  onChanged: (bool value) {
                    future() async {
                      if (value) {
                        await FlutterBluetoothSerial.instance
                            .requestEnable();
                      } else {
                        await FlutterBluetoothSerial.instance
                            .requestDisable();
                      }

                      await getPairedDevices();
                      _isButtonUnavailable = false;

                      if (_connected) {
                        _disconnect();
                      }
                    }

                    future().then((_) {
                      setState(() {});
                    });
                  },
                )
              ],
            ),
            //----------------------------------------------------------------
            Divider(height: 8,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Text("PAIRED DEVICES",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF005f81), letterSpacing: 2),
                ),
                IconButton(onPressed: () async {
                  // On pressing the refresh icon => refresh paired devices list
                  await getPairedDevices().then((_) {
                    show('Device list refreshed');
                  });
                }, icon: Icon(Icons.refresh_rounded, size: 28, color: Color(0xFF005f81))),

              ],
            ),
            Expanded(
              child: _getDeviceItems().length > 0
                  ? ListView.builder(
                shrinkWrap: true,
                itemCount: _getDeviceItems().length,
                itemBuilder: (BuildContext context, int index) {
                  var deviceItems =  _getDeviceItems();
                  return ListTile(
                    title: Text('${luciana[index]}',
                      style: TextStyle(
                          fontSize: 12.8, fontWeight: FontWeight.bold, color: Color(0xBF000000)
                      ),),
                    trailing: Icon(Icons.settings, size: 20, color: Color(0xFF005f81)),


                  );
                },
              )
                  : const Center(child: Text('No items')),
            ),

            // Stack(
            //   children: <Widget>[
            //     Column(
            //       children: <Widget>[
            //         Padding(
            //           padding: const EdgeInsets.only(top: 10),
            //           child: Text(
            //             "PAIRED DEVICES",
            //             style: TextStyle(fontSize: 24, color: Colors.blue),
            //             textAlign: TextAlign.center,
            //           ),
            //         ),
            //         Padding(
            //           padding: const EdgeInsets.all(8.0),
            //           child: Row(
            //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //             children: <Widget>[
            //               Text(
            //                 'Device:',
            //                 style: TextStyle(
            //                   fontWeight: FontWeight.bold,
            //                 ),
            //               ),
            //               DropdownButton(
            //                 items: _getDeviceItems(),
            //                 onChanged: (value) =>
            //                     setState(() => _device = value),
            //                 value: _devicesList.isNotEmpty ? _device : null,
            //               ),
            //               RaisedButton(
            //                 onPressed: _isButtonUnavailable
            //                     ? null
            //                     : _connected ? _disconnect : _connect,
            //                 child:
            //                 Text(_connected ? 'Disconnect' : 'Connect'),
            //               ),
            //             ],
            //           ),
            //         ),
            //         Padding(
            //           padding: const EdgeInsets.all(16.0),
            //           child: Card(
            //             shape: RoundedRectangleBorder(
            //               side: new BorderSide(
            //                 color: _deviceState == 0
            //                     ? colors['neutralBorderColor']
            //                     : _deviceState == 1
            //                     ? colors['onBorderColor']
            //                     : colors['offBorderColor'],
            //                 width: 3,
            //               ),
            //               borderRadius: BorderRadius.circular(4.0),
            //             ),
            //             elevation: _deviceState == 0 ? 4 : 0,
            //             child: Padding(
            //               padding: const EdgeInsets.all(8.0),
            //               child: Row(
            //                 children: <Widget>[
            //                   Expanded(
            //                     child: Text(
            //                       "DEVICE 1",
            //                       style: TextStyle(
            //                         fontSize: 20,
            //                         color: _deviceState == 0
            //                             ? colors['neutralTextColor']
            //                             : _deviceState == 1
            //                             ? colors['onTextColor']
            //                             : colors['offTextColor'],
            //                       ),
            //                     ),
            //                   ),
            //                   FlatButton(
            //                     onPressed: _connected
            //                         ? _sendOnMessageToBluetooth
            //                         : null,
            //                     child: Text("ON"),
            //                   ),
            //                   FlatButton(
            //                     onPressed: _connected
            //                         ? _sendOffMessageToBluetooth
            //                         : null,
            //                     child: Text("OFF"),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //     Container(
            //       color: Colors.blue,
            //     ),
            //   ],
            // ),
            Divider(height: 8,),
            SizedBox(height: 16,),
            Text("NOTE: If you cannot find the device in the list, please pair the device by going to the Bluetooth Settings!",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15),
            // RaisedButton(
            //   elevation: 2,
            //   child: Text("Bluetooth Settings"),
            //   onPressed: () {
            //     FlutterBluetoothSerial.instance.openSettings();
            //   },
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                // RaisedButton(
                //   elevation: 2,
                //   child: Text("Settings"),
                //   onPressed: () {
                //     FlutterBluetoothSerial.instance.openSettings();
                //   },
                // ),
                Container(
                    padding: EdgeInsets.only(top: 0.0, bottom: 0.0, right: 16.0, left: 16.0),

                    decoration: BoxDecoration(
                      borderRadius: new BorderRadius.circular(20.0),
                      border: Border.all(color: Color(0xBFd3d3d3), width: 1),
                    ),
                    width: 136.0,


                    child: TextButton(
                      child: Text('FILES',
                          style: TextStyle(color: Color(0xFF005f81), fontSize: 12.0, fontWeight: FontWeight.bold, letterSpacing: 2,)),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => BluetoothApp()));
                      },
                    )
                ),

                Container(
                    padding: EdgeInsets.only(top: 0.0, bottom: 0.0, right: 16.0, left: 16.0),

                    decoration: BoxDecoration(
                      borderRadius: new BorderRadius.circular(20.0),
                      border: Border.all(color: Color(0xBFd3d3d3), width: 1),
                    ),
                    width: 136.0,

                    child: TextButton(
                      child: Text('SETTINGS',
                          style: TextStyle(color: Color(0xFF005f81), fontSize: 12.0, fontWeight: FontWeight.bold, letterSpacing: 2,)),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => BluetoothApp()));
                      },
                    )
                ),
              ],
            )
            // Row(
            //   children: [
            //     Container(
            //         padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
            //
            //         decoration: BoxDecoration(
            //           borderRadius: new BorderRadius.circular(24.0),
            //           border: Border.all(color: Color(0xFFd3d3d3), width: 1),
            //         ),
            //         width: double.infinity,
            //
            //         child: TextButton(
            //           child: Text('BLUETOOTH SETTINGS',
            //               style: TextStyle(color: Color(0xFFe0115f), fontSize: 12.0, fontWeight: FontWeight.bold, letterSpacing: 2,)),
            //           onPressed: () {
            //             Navigator.push(context, MaterialPageRoute(builder: (context) => BluetoothApp()));
            //           },
            //         )
            //     ),
            //     Container(
            //         padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
            //
            //         decoration: BoxDecoration(
            //           borderRadius: new BorderRadius.circular(24.0),
            //           border: Border.all(color: Color(0xFFd3d3d3), width: 1),
            //         ),
            //         width: double.infinity,
            //
            //         child: TextButton(
            //           child: Text('RECEIVED FILES',
            //               style: TextStyle(color: Color(0xFFe0115f), fontSize: 12.0, fontWeight: FontWeight.bold, letterSpacing: 2,)),
            //           onPressed: () {
            //             Navigator.push(context, MaterialPageRoute(builder: (context) => BluetoothApp()));
            //           },
            //         )
            //     ),
            //   ],
            // )
          ],
        ),
      ),
    );
  }

  // Create the List of devices to be shown in Dropdown Menu
  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];

    if (_devicesList.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devicesList.forEach((device) {
        print("===============");
        print(device.name);
        luciana.add(device.name);
        items.add(DropdownMenuItem(
          child: Text(device.name),
          value: device,
        ));
      });
    }
    print("+++++++++++++");
    print(luciana);
    return items;
  }



  // Method to connect to bluetooth
  void _connect() async {
    setState(() {
      _isButtonUnavailable = true;
    });
    if (_device == null) {
      show('No device selected');
    } else {
      if (!isConnected) {
        await BluetoothConnection.toAddress(_device.address)
            .then((_connection) {
          print('Connected to the device');
          connection = _connection;
          setState(() {
            _connected = true;
          });

          connection.input.listen(null).onDone(() {
            if (isDisconnecting) {
              print('Disconnecting locally!');
            } else {
              print('Disconnected remotely!');
            }
            if (this.mounted) {
              setState(() {});
            }
          });
        }).catchError((error) {
          print('Cannot connect, exception occurred');
          print(error);
        });
        show('Device connected');

        setState(() => _isButtonUnavailable = false);
      }
    }
  }

  // void _onDataReceived(Uint8List data) {
  //   // Allocate buffer for parsed data
  //   int backspacesCounter = 0;
  //   data.forEach((byte) {
  //     if (byte == 8 || byte == 127) {
  //       backspacesCounter++;
  //     }
  //   });
  //   Uint8List buffer = Uint8List(data.length - backspacesCounter);
  //   int bufferIndex = buffer.length;

  //   // Apply backspace control character
  //   backspacesCounter = 0;
  //   for (int i = data.length - 1; i >= 0; i--) {
  //     if (data[i] == 8 || data[i] == 127) {
  //       backspacesCounter++;
  //     } else {
  //       if (backspacesCounter > 0) {
  //         backspacesCounter--;
  //       } else {
  //         buffer[--bufferIndex] = data[i];
  //       }
  //     }
  //   }
  // }

  // Method to disconnect bluetooth
  void _disconnect() async {
    setState(() {
      _isButtonUnavailable = true;
      _deviceState = 0;
    });

    await connection.close();
    show('Device disconnected');
    if (!connection.isConnected) {
      setState(() {
        _connected = false;
        _isButtonUnavailable = false;
      });
    }
  }

  // Method to send message,
  // for turning the Bluetooth device on
  void _sendOnMessageToBluetooth() async {
    // connection.output.add(utf8.encode("1" + "\r\n"));
    await connection.output.allSent;
    show('Device Turned On');
    setState(() {
      _deviceState = 1; // device on
    });
  }

  // Method to send message,
  // for turning the Bluetooth device off
  void _sendOffMessageToBluetooth() async {
    // connection.output.add(utf8.encode("0" + "\r\n"));
    await connection.output.allSent;
    show('Device Turned Off');
    setState(() {
      _deviceState = -1; // device off
    });
  }

  // Method to show a Snackbar,
  // taking message as the text
  Future show(
      String message, {
        Duration duration: const Duration(seconds: 3),
      }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    _scaffoldKey.currentState!.showSnackBar(
      new SnackBar(
        content: new Text(
          message,
        ),
        duration: duration,
      ),
    );
  }
}