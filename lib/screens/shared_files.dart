// import 'dart:html';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:open_file/open_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:blue/globals.dart';
import 'package:blue/screens/menu/menu.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:loading_overlay/loading_overlay.dart';


class SharedFiles extends StatefulWidget {
  const SharedFiles({Key? key}) : super(key: key);

  @override
  _SharedFilesState createState() => _SharedFilesState();
}

class _SharedFilesState extends State<SharedFiles> {
  /*
  * VARIABLES:
  * files - received .txt files
  * pressed - keeps track of appBar -> setting it as either in default mode or select mode
  * itemPresssed - itemPressed[1] = true -> item is selected
  * selectedItemsPaths
  */

  var files;
  bool pressed = false;
  var itemPressed = [];
  var selectedItemsPath = [];

  late bool permissionGranted;

  //----------------------------------------------------------------------------

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference logs = FirebaseFirestore.instance.collection('logs');

  final secureStorage = new FlutterSecureStorage();

  //----------------------------------------------------------------------------
  // Upload files to firebase storage
  Future<void> uploadFile() async {
    try {
      selectedItemsPath.forEach((element) async {
        File file = File(element);
        await firebase_storage.FirebaseStorage.instance
            .ref('${element.split('/').last}')
            .putFile(file)
            .then((value) =>
              setState(() async {
                Navigator.pop(context, false);
                uploadSuccess();
                logUpload('${element.split('/').last}');
              })
        );
      });
    } on FirebaseException catch (err) {

      print("$err");

      setState(() {
        Navigator.pop(context, false);
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Icon(Icons.error, color: Colors.red, size: 36,),
                content:  Text('An error has occurred', textAlign: TextAlign.center,),
              );
            }
        );
      });
    }
  }

  logUpload(fileName) async {
    // String? username = await secureStorage.read(key: 'username');

    try{
      logs.add(
        {
          'timestamp': DateTime.now(),
          'userName': user,
          'fileName': fileName,
        }
      );
    }catch(err){
      print(err);

      setState(() {
        Navigator.pop(context, false);
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Icon(Icons.error, color: Colors.red, size: 36,),
                content:  Text('An error has occurred', textAlign: TextAlign.center,),
              );
            }
        );
      });
    }
  }

  uploadSuccess(){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          Future.delayed(Duration(seconds: 1)).then((_) {
            pressed = false;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SharedFiles()),
            );
            // Navigator.pop(context, false);
          });


          return AlertDialog(
            title: Icon(Icons.check_circle_rounded, size: 48, color: Colors.green,),
            content:  Text('Successfully Uploaded', textAlign: TextAlign.center,),
          );
        }
    );
  }

  sendFiles() {

    if(connectivityRes == "ConnectivityResult.none"){
      setState(() {
        Navigator.pop(context, false);
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Icon(Icons.error, color: Colors.red, size: 36,),
                content:  Text('Connect to the internet!', textAlign: TextAlign.center,),
              );
            }
        );
      });
    }else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('UPLOAD ITEMS',  style: TextStyle(color: Color(0xFFe0115f), fontSize: 14.0, letterSpacing: 2.4), textAlign: TextAlign.center,),
              content: Text('Confirm upload of ${itemPressed.where((element) => element == true).length} item(s)?', textAlign: TextAlign.center,),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    TextButton(onPressed: () {
                      uploadFile();
                      setState(() {
                        Navigator.pop(context, false);
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: SpinKitCircle(color: Color(0xFFe0115f), size: 70.0),
                                content:  Text('Uploading item(s)', textAlign: TextAlign.center,),
                              );
                            }
                        );
                      });
                    },
                      child: Text('CONFIRM', style: TextStyle(color: Colors.green, fontSize: 14.0, letterSpacing: 2.4),),
                    ),
                    TextButton(onPressed: (){
                      Navigator.pop(context, false);
                    },
                      child: Text('CANCEL', style: TextStyle(color: Color(0xFF005f81), fontSize: 14.0, letterSpacing: 2.4),),
                    )
                  ],
                )
              ],

            );
          }
      );
    }
  }

  //----------------------------------------------------------------------------
  // Open files => .txt files opened with Chrome app
  Future<void> openFile(filePath) async {
    setState(() async {
      await OpenFile.open(filePath);
    });
  }

  //----------------------------------------------------------------------------
  // Get Bluetooth files
  void getFiles() async{
    List<StorageInfo> storageInfo = await PathProviderEx.getStorageInfo();
    var root = storageInfo[0].rootDir; //storageInfo[1] for SD card, geting the root directory
    var fm = FileManager(root: Directory(root)); //
    files = await fm.filesTree(
        //set fm.dirsTree() for directory/folder tree list
        excludedPaths: ["/storage/emulated/0/Bluetooth"],
        extensions: ["txt"]
    );
    setState(() {});
  }
  //----------------------------------------------------------------------------

  Future<void> requestPermission() async {
    if (await Permission.storage.request().isGranted) {
      setState(() {
        permissionGranted = true;
      });
    } else if (await Permission.storage.request().isPermanentlyDenied) {
      await openAppSettings();
    } else if (await Permission.storage.request().isDenied) {
      setState(() {
        permissionGranted = false;
      });
    }
    super.initState();
  }

  @override
  void initState() {
    requestPermission();
    getFiles(); //call getFiles() function on initial state.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFffffff),
        iconTheme: IconThemeData(color: Color(0xFF005f81)),
        elevation: 2.0,
        toolbarHeight: 68.0,
        titleSpacing: 0,

        automaticallyImplyLeading: pressed ? false : true,
        title: pressed ?
              Row(children: [
                IconButton(onPressed: (){
                  setState(() {
                    pressed = !pressed;
                  });
                }, icon: Icon(Icons.arrow_back, size: 28)),
                Text("${itemPressed.where((element) => element == true).length} selected item(s)", style: TextStyle(color: Color(0xFFe0115f), fontSize: 14.0, fontWeight: FontWeight.bold, letterSpacing: 2)),
              ],)
            :
              Text('RECEIVED FILES',
                  style: TextStyle(color: Color(0xFFe0115f), fontSize: 14.0, fontWeight: FontWeight.bold, letterSpacing: 2)),
        actions: pressed ?
          [Icon(Icons.delete, size: 24), SizedBox(width: 12,),
          IconButton(onPressed: (){
            sendFiles();
          }, icon: Icon(Icons.send, size: 24)),
          SizedBox(width: 20,)] :
          [Icon(Icons.search_rounded, size: 28), SizedBox(width: 10,),IconButton(onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Menu()),
            );
          }, icon: Icon(Icons.more_vert, size: 28),), SizedBox(width: 16,)],
       ),

        //----------------------------------------------------------------------
        body: files == null ?
        Column(mainAxisAlignment: MainAxisAlignment.center,children: [SpinKitCircle(color: Color(0xFFe0115f), size: 70.0),SizedBox(height: 20,), Text("Searching files ...")]):
        Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),

          child: ListView.builder(  //if file/folder list is grabbed, then show here
            itemCount: files?.length ?? 0,
            itemBuilder: (context, index) {
              itemPressed.add(false);
              return GestureDetector(
                child: ListTile(
                  title: Text(files[index].path.split('/').last),
                  leading: Icon(Icons.insert_drive_file, size: 20, color: Color(0xFFc0c0c0)),
                  trailing: pressed ? Icon(Icons.check_circle, color: itemPressed[index] ? Color(0xFF005f81) : Color(0xFFc0c0c0),) : null,
                ),
                onLongPress: (){
                  setState(() {
                    pressed = true;
                    itemPressed[index] = !itemPressed[index];
                    selectedItemsPath.add('${files[index].path}');
                  });
                },
                onTap: (){
                   if(pressed){
                      setState(() {
                        itemPressed[index] = !itemPressed[index];
                        selectedItemsPath.add('${files[index].path}');
                      });
                   }
                },
                onDoubleTap: (){
                  openFile('${files[index].path}');
                },
              );
            },
          ),
        )
    );
  }
}
