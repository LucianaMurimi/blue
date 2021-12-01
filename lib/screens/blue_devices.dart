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

  // To track whether the device is still connected to Bluetooth
  bool get isConnected => connection != null && connection.isConnected;

  List<BluetoothDevice> _devicesList = [];
  late BluetoothDevice _device;
  bool _connected = false;
  bool _isButtonUnavailable = false;

  var pairedDevicesList = [];

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
      print("getPairedDevices() => PlatformException");
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SharedFiles()),
            );
          }, icon: Icon(Icons.folder_open_rounded, size: 28)),
          SizedBox(width: 10,),
          IconButton(onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Menu()),
            );
          }, icon: Icon(Icons.menu_rounded, size: 28)),
          SizedBox(width: 20,),
        ],
      ),
      //------------------------------------------------------------------------

      body: Container(
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),

        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            //------------------------------------------------------------------
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
                    // TODO: Snackbar to notify user of refresh
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
                        return ListTile(
                          title: Text('${pairedDevicesList[index]}',
                            style: TextStyle(
                                fontSize: 12.8, fontWeight: FontWeight.bold, color: Color(0xBF000000)
                            ),),
                          trailing: Icon(Icons.settings, size: 20, color: Color(0xFF005f81)),
                        );
                      },
                    )
                  : Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 28),
                        SizedBox(height: 12,),
                        Text("No Paired Devices found."),
                      ],)),
            ),
            Divider(height: 8,),

            //------------------------------------------------------------------
            SizedBox(height: 16,),

            Text("NOTE: If you cannot find the device in the list, please pair the device by going to the Bluetooth Settings!",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red,),
              textAlign: TextAlign.center,
            ),

            //------------------------------------------------------------------
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SharedFiles()),
                        );
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
            //------------------------------------------------------------------
          ],
        ),
      ),
    );
  }


  //============================================================================
  // Create the List of devices to be shown in Dropdown Menu
  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    _devicesList.forEach((device) {
        pairedDevicesList.add(device.name);
        items.add(DropdownMenuItem(
          child: Text(device.name),
          value: device,
        ));
      });
    return items;
  }

  //----------------------------------------------------------------------------
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
  //----------------------------------------------------------------------------
  // Method to show a Snackbar,
  void show(message) {
    setState(() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$message', style: TextStyle(color: Colors.white), textAlign: TextAlign.center,),
          backgroundColor: Color(0xFF000000),),
      );
    });
  }

}