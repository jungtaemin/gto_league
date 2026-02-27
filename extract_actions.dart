import 'dart:convert';
import 'dart:io';

Set<String> uniqueActions = {};

void extractActions(dynamic data) {
  if (data is Map) {
    for (var entry in data.entries) {
      if (entry.key == 'actions' || entry.key == 'action') {
        if (entry.value is List) {
          for (var item in entry.value) {
             uniqueActions.add(item.toString());
          }
        } else {
             uniqueActions.add(entry.value.toString());
        }
      } else if (entry.key == 'sequence') {
        // sequences often contain actions like "F", "C", "R"
        uniqueActions.add("sequence: ${entry.value}");
      }
      extractActions(entry.value);
    }
  } else if (data is List) {
    for (var item in data) {
      extractActions(item);
    }
  }
}

void main() async {
  var baseDir = r'c:\Users\jtm02\Desktop\antigravity\allinfold\holdem_allin_fold\assets\db';
  
  print('=== Extracting Unique Actions from 0.json ~ 10.json ===');
  for (int i = 0; i <= 10; i++) {
    var file = File('$baseDir\\$i.json');
    if (await file.exists()) {
      var content = await file.readAsString();
      dynamic data = jsonDecode(content);
      extractActions(data);
    }
  }
  print('Unique actions in 0~10.json:');
  for (var action in uniqueActions.where((a) => !a.startsWith('sequence:'))) {
      print(' - $action');
  }
  
  Set<String> sequences = uniqueActions.where((a) => a.startsWith('sequence:')).toSet();
  print('Sample sequences in 0~10.json: ${sequences.take(10).toList()}');
  
  uniqueActions.clear();

  print('\n=== Extracting Unique Actions from master_30bb.json.gz ===');
  var gzFile = File('$baseDir\\master_30bb.json.gz');
  if (await gzFile.exists()) {
    var bytes = await gzFile.readAsBytes();
    var decompressed = gzip.decode(bytes);
    var content = utf8.decode(decompressed);
    
    dynamic data = jsonDecode(content);
    extractActions(data);
    
    print('Unique actions in master_30bb.json.gz:');
    for (var action in uniqueActions.where((a) => !a.startsWith('sequence:'))) {
        print(' - $action');
    }
    Set<String> gzSequences = uniqueActions.where((a) => a.startsWith('sequence:')).toSet();
    print('Sample sequences in master_30bb.json.gz: ${gzSequences.take(10).toList()}');
  }
}
