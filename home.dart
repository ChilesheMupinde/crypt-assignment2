import 'package:dapp7/Screen/NewCampaign.dart';
import 'package:dapp7/Screen/campaingdetails.dart';
import 'package:dapp7/services/Funder_handler.dart';
import 'package:dapp7/services/backend.dart';
import 'package:dapp7/utils/constants.dart';
import 'package:dapp7/utils/input_wiget.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';
import '../models/campaign_model.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Client? httpclient;
  Web3Client? web3client;
  Campaigncontroller? campaigncontroller;
  Fundcontroller? fundcontroller;
  List<Campaign>? campaigns;
  @override
  void initState() {
    // TODO: implement initState
    httpclient = Client();
    web3client = Web3Client(WebsocketUrl, httpclient!);
  }

  Future<void> getbalance(String targetaddress)async {
    EthereumAddress address = EthereumAddress.fromHex(targetaddress);
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size *.9;
    campaigncontroller = Provider.of<Campaigncontroller>(context);
    final TextEditingController addedamount = TextEditingController();
    campaigns = campaigncontroller!.campaigns;
    print(campaigncontroller!.isLoading);
    print(campaigns!.length);

    return ChangeNotifierProvider(
      create: (context) => Fundcontroller(),
    builder: (context, prochild) {
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 96,
            leading:Image.asset(
              assetimage3,
              height: 320,
              width: 320,
            ),
            backgroundColor: Colors.blue.withOpacity(0.4),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    padding: const EdgeInsets.all(8.0), child: Text(" Thank you for being a contributor! ",
                    style: GoogleFonts.daiBannaSil(fontSize: 20)))
              ],

            ),
          ),
          backgroundColor: Colors.blue.withOpacity(0.1),
          floatingActionButton: FloatingActionButton(
            onPressed: (){
              Get.to(CampaignScreen());
            },
            child: Icon(Icons.add),
          ),
          body: Container(
            width: _size.width,
            height: _size.height,
            child: SingleChildScrollView(
              child: campaigncontroller!.isLoading?
              Center(
                child: CircularProgressIndicator(),
              ) :
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                     height: MediaQuery.of(context).size.height *0.9,
                     width: 660,
                     child: ListView.builder(
                      itemCount: campaigns!.length, padding: EdgeInsets.only(left: 24, right: 24, bottom: 24),
                       itemBuilder: (BuildContext context, int index) {

                         Deposit() async{
                           await campaigncontroller!.contribute(int.parse(campaigns![index].id!),
                               int.parse(addedamount.text));
                         }

                         return Card(
                           margin: const EdgeInsets.all(10),
                           elevation: 20,
                           shape: RoundedRectangleBorder(
                               side: BorderSide(width: 3, color: Colors.blue.withOpacity(0.4)),
                               borderRadius: BorderRadius.all(Radius.circular(15))),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               SizedBox(height: 20,),
                               Text(
                                 "  ${campaigns![index].title}",
                                 style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),),
                               SizedBox(height: 20,),
                               Row(
                                 children: [
                                   Text("  Target: ", style: GoogleFonts.montserrat()),
                                   Text(
                                    " ETH ${campaigns![index].targetAmount.toString()}", style: GoogleFonts.montserrat())
                                 ],
                               ),
                               SizedBox(height: 20,),
                               Row(
                                 children: [
                                   SizedBox(width: 5,),
                                   ElevatedButton(onPressed: (){
                                     showDialog(
                                       context: context,
                                       builder: (context) => AlertDialog(
                                         actionsPadding:
                                         const EdgeInsets.symmetric(vertical: 30),
                                         actionsAlignment: MainAxisAlignment.center,
                                         actions: [
                                           TextFormField(controller: addedamount,
                                           decoration: textInputDecoration.copyWith(

                                           ),),
                                           const SizedBox(
                                             height: 20,
                                           ),
        
                                           ElevatedButton(onPressed: (){
                                             Navigator.pop(context);
                                             Deposit();
        
                                           },
                                               child: Text("Add amount"))
                                         ],
                                       ),
                                     );
                                   },
                                       child: Text("Donate", style: GoogleFonts.montserrat())),
                                   SizedBox(width: 290,),
                                   TextButton(onPressed: (){
                                     Get.to(Campdetailscreen(campaign: campaigns![index]));
                                   },
                                       child: Text("See more")),
                                 ],
                               ),
                               SizedBox(height: 10,)
        
                             ],
                           ),
                         );
                       }),
                   ),
                ],
              ),
            ),
          ),
        
        
        
        ),
      );}
    );

  }

}

Widget _head() {
  return Stack(
    children: [
      Column(
        children: [
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.blue.withOpacity(0.3), Colors.blue.withOpacity(0.3),
                    Colors.blue.withOpacity(0.4)]),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 35, left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(width: 320,),
                          Text(
                            'Z-funds',
                            style: GoogleFonts.acme(
                              fontWeight: FontWeight.bold,
                              fontSize: 45,
                              color: Colors.white,
                            ),
                          ),

                          Image(
                            image: AssetImage(assetimage1),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    ],
  );
}






