import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Web3Utils {

  final Client httpClient = Client();
  final Web3Client ethereumClient = Web3Client(dotenv.env['WEB3_ENDPOINT'] as String, Client());

  Future<DeployedContract> getContract() async {
  // abi.json is the contract metadata, you can download it from the remix IDE
  String abi = await rootBundle.loadString("assets/web3/abi.json");
  String contractAddress = dotenv.env['CONTRACT_ADDRESS'] as String; // e.g. 0xd66C81d9b781152e2D9be07Ccdf2303A77B7163c
  String contractName = dotenv.env['CONTRACT_NAME'] as String; // you must set your own contract name here

  DeployedContract contract = DeployedContract(
    ContractAbi.fromJson(abi, contractName),
    EthereumAddress.fromHex(contractAddress),
  );

  return contract;
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
  DeployedContract contract = await getContract();
  ContractFunction function = contract.function(functionName);
  try {
    List<dynamic> result = await ethereumClient.call(
      contract: contract, function: function, params: args);
    return result;
  } catch (e) {
    List<dynamic> result = [];
    result.add(e);
    return result;
  }
  }

  Future<String> transaction(String functionName, List<dynamic> args) async {
    EthPrivateKey credential = EthPrivateKey.fromHex(dotenv.env['WEB3_CREDENTIAL'] as String);
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
      dynamic result = [];
      result.add(e);
      return result;
    }
  }

  Future<List<dynamic>> getRecords() async {
    List<dynamic> result = await query('getRecords', []);
    return result[0];
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