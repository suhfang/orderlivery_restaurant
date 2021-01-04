


import 'package:Restaurant/auth.dart';
import 'package:Restaurant/printer_helper.dart';
import 'package:flutter/material.dart';

class AddPrinterPage extends StatefulWidget {
    AddPrinterPageState createState() => AddPrinterPageState();
}

class AddPrinterPageState extends State<AddPrinterPage> {

  TextEditingController nameController = TextEditingController();
  TextEditingController ipController = TextEditingController();

  void initState() {
    super.initState();
    initPrinterDB();
  }

  initPrinterDB() async {
    await PrinterProvider.shared.open('printer.db');
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('ADD PRINTER'),
        backgroundColor: Colors.orange,
        shadowColor: Colors.transparent,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(20),
         child: Column(
           children: [
             SizedBox(height: 40,),
             TTextFormField(
               controller: nameController,
              hintText: 'Enter Printer name',
             ),
              SizedBox(height: 10,),
              TTextFormField(
                controller: ipController,
               hintText: 'Enter Printer IP. Ex 192.168.1.2',
              ),
              SizedBox(
                height: 40
              ),
              GestureDetector(
                onTap: () async {
                  var name = nameController.text.trim();
                  var ip = ipController.text.trim();
                  RegExp regexp = new RegExp(r"^(?!0)(?!.*\.$)((1?\d?\d|25[0-5]|2[0-4]\d)(\.|$)){4}$", caseSensitive: false, multiLine: false);
                   var printers = await PrinterProvider.shared.getAllPrinters();
                   
                  if (name.isNotEmpty && ip.isNotEmpty  && regexp.hasMatch(ip)) {
                  //  print(printers[1].isDefault);
                  //  print(printers[0].isDefault);
                    var printer = Printer(
                      name: name,
                      ip: ip,
                      isDefault: printers.length == 0 ? 1 : 0
                    );
                    PrinterProvider.shared.addPrinter(printer);
                    // // print('printer was added');
                    Navigator.pop(context);
                  }
                },
                child: Container(
                height: 50,
                
                child: Center(
                  child: Text('ADD PRINTER', style: TextStyle(fontWeight: FontWeight.bold),),
                ),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(30)
                ),
              )
              )
           ],
         )
        ),
      ),
    );
  }
}