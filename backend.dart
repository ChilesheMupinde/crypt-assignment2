import 'dart:convert';
import 'dart:developer';
import 'package:dapp7/models/campaign_model.dart';
import 'package:dapp7/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';


class Campaigncontroller extends ChangeNotifier{
  List<Campaign> campaigns = [];
  int? num_of_campaigns;
  EthPrivateKey? credentials;
  EthereumAddress? useraddress;
  bool isLoading = true;

  late ContractFunction createCampaign;
  late ContractFunction _campaigns;

  Web3Client? Ethclient;
  Client? httpClient;
  late String Abicode;
  late Credentials _credentials;
  late DeployedContract _contract;
  late EthereumAddress contractaddress;
  late EthPrivateKey _key;

  Campaigncontroller(){
    _Init();
  }

  Future<void> getABI() async {
    String Abifile = await rootBundle
        .loadString("build/contracts/Crowdfunding.json");
    var JsonABI = json.decode(Abifile);
    Abicode = jsonEncode(JsonABI['abi']);
    contractaddress =   EthereumAddress.fromHex(JsonABI["networks"]["5777"]["address"]);
  }

  late Credentials _creds;

  Future<void> getCredentials() async {
    _creds =  await EthPrivateKey.fromHex(privatekey);
    useraddress = await _creds.address;
  }

  late DeployedContract _deployedcontract;
  late ContractFunction _createcampaign;
  late ContractFunction _donate;
  late ContractFunction _withdrawfunder;
  late ContractFunction _deletecamp;
  late ContractFunction getcamp;
  late ContractFunction _camps;

  Future<DeployedContract> loadcontract()async{
    String abi = await rootBundle.loadString('assets/abi.json');
    String ContractAddress = ContractAddress1;
    final contract = DeployedContract(ContractAbi.fromJson(abi, 'Crowdfunding'),
        EthereumAddress.fromHex(ContractAddress));
    return contract;
  }

  Future<String> callFunction(String funcname, List<dynamic> args,
      Web3Client EthClient, String privateKey) async {
    EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey);
    DeployedContract contract = await loadcontract();
    final ethFunction = contract.function(funcname);
    final result = await EthClient.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: contract,
          gasPrice: EtherAmount.fromInt(EtherUnit.gwei, 3),
          maxGas: 23000,
          function: ethFunction,
          parameters: args,

          // maxFeePerGas: EtherAmount.fromInt(EtherUnit.ether, 788177330)
        ),
        chainId: 1337,
        fetchChainIdFromNetworkId: false

    );
    return result;
  }

  Future<void> getdeployedContracts() async {
    _deployedcontract = DeployedContract(
        (ContractAbi.fromJson(Abicode, "Crowdfunding")), contractaddress);
    _createcampaign = _deployedcontract.function("createcampaign");
    _donate = _deployedcontract.function("donate");
    _deletecamp = _deployedcontract.function("deleteCamp");
    getcamp = _deployedcontract.function("num_of_campaigns");
    _camps = _deployedcontract.function("campaigns");
    await getCampaigns();
  }

  Future<String> donate(int id, Web3Client user)async{
    var response = await callFunction('donate', [BigInt.from(id)], user, funder_privatekey);
    print("Campaign created succesfully");
    return response;
  }

  _Init() async {
    httpClient = Client();
    Ethclient = Web3Client(rpcUrl, httpClient!);
    await getABI();
    await getCredentials();
    await getdeployedContracts();
  }

  getCampaigns() async {
    List CampaignList = await Ethclient!
        .call(contract: _deployedcontract, function: getcamp, params: [],);
    BigInt totalNotes = CampaignList[0];
    num_of_campaigns = totalNotes.toInt();
    campaigns.clear();
    for (int i = 0; i < num_of_campaigns!; i++) {
      var temp = await Ethclient!.call(
          contract: _deployedcontract,
          function: _camps,
          params: [BigInt.from(i)]);
      if (temp[1] != "")
        campaigns.add(
          Campaign(
            id: temp[0].toString(),
            User: temp[1],
            title: temp[2],
            Description: temp[3],
            deadline: temp[4],
            targetAmount: temp[5],
            collectedamount: temp[6],
            image: temp[7]
            ),
        );
    }
    isLoading = false;
    notifyListeners();
  }

  addCampaign(Campaign campaign) async {
    isLoading = true;
    notifyListeners();
    await Ethclient!.sendTransaction(
        _creds,
        Transaction.callContract(
          contract: _deployedcontract,
          function: _createcampaign,
          parameters: [
            campaign.User,
            campaign.title,
            campaign.Description,
            campaign.targetAmount,
            campaign.deadline,
            campaign.image
          ],
          gasPrice: EtherAmount.fromInt(EtherUnit.gwei, 3),
        ),
        chainId: 1337,
        fetchChainIdFromNetworkId: false
    );
    await getCampaigns();
  }

  Future<void> contribute(int campaignId, int amount) async {
    try {
      var contributeFunction = _deployedcontract.function('contribute');
      await Ethclient!.sendTransaction(
        _credentials,
        chainId: 1337,
        fetchChainIdFromNetworkId: false,
        Transaction.callContract(
          contract: _deployedcontract,
          function: contributeFunction,
          parameters: [BigInt.from(campaignId), BigInt.from(amount)],
        ),
      );
      isLoading = true;
      getCampaigns();
    } catch (e) {
      log(e.toString());
    }
  }



    deleteCamps(int id) async {
    isLoading = true;
    notifyListeners();
    await Ethclient!.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: _deletecamp,
        parameters: [BigInt.from(id)],
      ),
    );
    await getCampaigns();
  }
}
//Creating a new campaign


