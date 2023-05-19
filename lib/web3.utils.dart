import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class Web3Utils {
  late Client httpClient;
  late Web3Client ethereumClient;


  String initializer(ethereumClientUrl) {
    try {
      Client httpClient = Client();
      ethereumClient = Web3Client(ethereumClientUrl, httpClient);
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  Future<DeployedContract> getContract() async {
  // abi.json is the contract metadata, you can download it from the remix IDE
  String abi = await rootBundle.loadString("assets/web3/abi.json");
  String contractAddress = "0x33b8e500633d7b886cc3962c08333a57e954070e"; // e.g. 0xd66C81d9b781152e2D9be07Ccdf2303A77B7163c
  String contractName = "ClassifiedData"; // you must set your own contract name here

  DeployedContract contract = DeployedContract(
    ContractAbi.fromJson(abi, contractName),
    EthereumAddress.fromHex(contractAddress),
  );

  return contract;
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    print("entered query");
  DeployedContract contract = await getContract();
  ContractFunction function = contract.function(functionName);
  try {
    List<dynamic> result = await ethereumClient.call(
      contract: contract, function: function, params: args);
      print('$result this is the result in query');
    return result;
  } catch (e) {
    print('$e this is the error in query');
    List<dynamic> result = [];
    result.add(e);
    return result;
  }
  }

  Future<String> transaction(String functionName, List<dynamic> args) async {
    EthPrivateKey credential = EthPrivateKey.fromHex('1ea2623ebc03dbe22ad83a2caa8b54dc7b1100d1c87ab823786b7eda1734ef21');
    DeployedContract contract = await getContract();
    ContractFunction function = contract.function(functionName);
    dynamic result = await ethereumClient.sendTransaction(
      credential,
      Transaction.callContract(
        contract: contract,
        function: function,
        parameters: args,
      ),
      fetchChainIdFromNetworkId: true,
      chainId: null,
    );

    return result;
  }

  Future<dynamic> addRecord(List<dynamic> args) async {
    try {
      dynamic result = await transaction('addRecord', args);
      return result[0];
    } catch (e) {
      print('$e this is the error in add record');
      dynamic result = [];
      result.add(e);
      return result;
    }
  }

  Future<String> getRecords() async {
    List<dynamic> result = await query('getRecords', []);
    return result[0].toString();
  }

  dynamic support(List<dynamic> args) async {
    dynamic result = await transaction('support', args);
    return result[0];
  }

  Future<String> oppose(List<dynamic> args) async {
    List<dynamic> result = await query('oppose', args);
    return result[0].toString();
  }

  Future<String> getOpposers(List<dynamic> args) async {
    List<dynamic> result = await query('addRecord', args);
    return result[0].toString();
  }

  Future<String> getSupporters(List<dynamic> args) async {
    List<dynamic> result = await query('addRecord', args);
    return result[0].toString();
  }
}