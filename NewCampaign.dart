import 'dart:convert';
import 'dart:io';
import 'package:dapp7/models/campaign_model.dart';
import 'package:dapp7/services/backend.dart';
import 'package:dapp7/utils/constants.dart';
import 'package:dapp7/utils/input_wiget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';
import 'home.dart';

class CampaignScreen extends StatefulWidget {
  final Campaign? campaign;

  const CampaignScreen({super.key,this.campaign
  });

  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen> {


  final ImagePicker _picker = ImagePicker();
  final _formkey = GlobalKey<FormState>();
  XFile? _image;
  Campaigncontroller? campaigncontroller;
  List<Campaign>? campaigns;
  Web3Client? Ethclient;
  Client? httpClient;
  late EthereumAddress contractaddress;
  late EthPrivateKey _key;
  //variables

@override
  void initState() {
  httpClient = Client();
  Ethclient = Web3Client(rpcUrl, httpClient!, socketConnector: () {
    return IOWebSocketChannel.connect(WebsocketUrl).cast<String>();});
    // TODO: implement initState
    print("initstate");
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // animationController.dispose() instead of your controller.dispose
  }
 
  @override

  Widget build(BuildContext context) {
  campaigncontroller = Provider.of<Campaigncontroller>(context);
      //secondvariables
  final now = DateTime.now();
  DateTime tommorrow = DateTime(now.year, now.month, now.day + 1);
  final TextEditingController namecontroller = TextEditingController();
  final TextEditingController Description = TextEditingController();
  final TextEditingController Amount = TextEditingController();
  final TextEditingController Titlecontroller = TextEditingController();
  _key = EthPrivateKey.fromHex("0xfb2411c5d550f797c75fc4430b181118d3407e29f201df910c84e18fcd6b2406");
  contractaddress = _key.address;

    Noteaddition()async{
      Campaign campaign = Campaign(
          title: Titlecontroller.text,
          Description: Description.text,
          User: contractaddress,
          collectedamount: BigInt.from(0),
          image: _image?.path,
          // collectedamount: BigInt.from(0),
          targetAmount: BigInt.from(int.parse(Amount.text)), 
           deadline: BigInt.from(tommorrow.day));
      await campaigncontroller!.addCampaign(campaign);
    }

    // addcampaign()async{
    //    await _campaigncontroller!.
    //    createCampaign;
    // }
    Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: tommorrow,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != tommorrow) {
      setState(() {
        tommorrow = picked;
      });
    }
  }

    Future getCametaImage() async {
    _image = await _picker.pickImage(source: ImageSource.camera);
    if (_image != null) {
      setState(() {
        _image;
      });
    }
  }

  Future getGalleryImage() async {
    _image = await _picker.pickImage(source: ImageSource.gallery);
    if (_image != null) {
      setState(() {
        _image;
      });
    }
  }

    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          child:Container(
            padding:const EdgeInsets.all(18),
            child: Form(
              key: _formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: InkWell(
                        onTap: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            actionsPadding:
                                const EdgeInsets.symmetric(vertical: 30),
                            actionsAlignment: MainAxisAlignment.center,
                            actions: [
                              FloatingActionButton(
                                onPressed: () {
                                  getCametaImage();
                                  Navigator.pop(context);
                                  // context.pop();
                                },
                                child: const Icon(Icons.camera_alt),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              FloatingActionButton(
                                onPressed: () {
                                  getGalleryImage();
                                  Navigator.pop(context);
                                  // context.pop();
                                },
                                child: const Icon(Icons.photo_library),
                              )
                            ],
                          ),
                        ),

                        child: CircleAvatar(
                            // radius: 35,
                            minRadius: 30,
                            maxRadius: 36,
                            // backgroundColor: Colors.transparent,
                            backgroundImage: _image != null
                                ? FileImage(File(_image!.path))
                                : null,
                            child: _image == null
                                ? const Icon(
                                    Icons.add_a_photo_outlined,
                                    color: Colors.blue,
                                    size: 30,
                                  )
                                : null),
                      ),
                  ),
                  const SizedBox(height: 20,),
                  Text("Name", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20,),
                  TextFormField(
                    controller: namecontroller,
                    decoration: textInputDecoration.copyWith(
                      ),
                     ),
                  const SizedBox(height: 20,),
                  Text("Title", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20,),
                  TextFormField(
                    controller: Titlecontroller,
                    decoration: textInputDecoration.copyWith(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  Text("Description", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),),
                  const SizedBox(height: 20,),
                  TextFormField(
                    maxLines: 5,
                    controller: Description,
                    decoration: textInputDecoration.copyWith(
                      border: OutlineInputBorder(),

                    ),
                  ),
                  const SizedBox(height: 20,),
                        Text("Target Amount", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20,),
                        TextFormField(
              keyboardType: TextInputType.number,
              controller: Amount,
              decoration: textInputDecoration.copyWith(
                border: OutlineInputBorder(),
              ),),
                        const SizedBox(height: 20,),
                        Text("Deadline", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10,),
                           ElevatedButton.icon(
                    onPressed: () => _selectDate(context),
                    icon: const Icon(Icons.calendar_month, color: Colors.blue),
                    label: Text(DateFormat('dd/MM/yyyy').format(tommorrow)),
                    style: ElevatedButton.styleFrom(
                        onPrimary: Colors.black, primary: Colors.white),
                  ),
                  const SizedBox(height: 20,),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      shape: BoxShape.rectangle
                    ),
                    child: ElevatedButton(onPressed:
                     (){
                    Noteaddition();
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => Home()),
                            (route) => false);
                    }, child: Text("Add new Campaign")),
                  )

                ],
              ),
            ),
          )
        ),
      )    );
  }
}

// (){
                //   Createcampaign(contractaddress, Titlecontroller.text,
                //       Description.text,
                //       int.parse(Amount.text),
                //       int.parse(tommorrow.day.toString()),
                //       Ethclient!);
                // } 

// if(widget.campaign == null){
//                   Noteaddition();
//                  }