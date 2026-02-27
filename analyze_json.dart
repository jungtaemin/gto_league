import 'dart:convert';
import 'dart:io';

int total3BetCount = 0;
Set<String> locations = {};

void search3Bet(dynamic data, String path) {
  if (data is Map) {
    for (var entry in data.entries) {
      String keyStr = entry.key.toString();
      if (keyStr.toUpperCase().contains('3BET')) {
        total3BetCount++;
        locations.add('$path -> Key: $keyStr');
      }
      search3Bet(entry.value, '$path.${entry.key}');
    }
  } else if (data is List) {
    for (var i = 0; i < data.length; i++) {
        var item = data[i];
        if (item is String && item.toUpperCase().contains('3BET')) {
             total3BetCount++;
             locations.add('$path[$i] -> Value: $item');
        } else {
             search3Bet(item, '$path[$i]');
        }
    }
  } else if (data is String) {
      if (data.toUpperCase().contains('3BET')) {
          total3BetCount++;
          locations.add('$path -> Value: $data');
      }
  }
}

void main() async {
  var baseDir = r'c:\Users\jtm02\Desktop\antigravity\allinfold\holdem_allin_fold\assets\db';
  
  print('=== Deep Analyzing 0.json ~ 10.json ===');
  for (int i = 0; i <= 10; i++) {
    var file = File('$baseDir\\$i.json');
    if (await file.exists()) {
      var content = await file.readAsString();
      dynamic data = jsonDecode(content);
      
      total3BetCount = 0;
      locations.clear();
      
      search3Bet(data, 'root');
      
      print('$i.json: Found $total3BetCount occurrences of 3BET.');
      if (locations.isNotEmpty) {
          print('Sample locations: ${locations.take(5).toList()}');
      }
    }
  }

  print('\n=== Deep Analyzing master_30bb.json.gz ===');
  var gzFile = File('$baseDir\\master_30bb.json.gz');
  if (await gzFile.exists()) {
    var bytes = await gzFile.readAsBytes();
    var decompressed = gzip.decode(bytes);
    var content = utf8.decode(decompressed);
    
    dynamic data = jsonDecode(content);
    
    total3BetCount = 0;
    locations.clear();
    
    search3Bet(data, 'root');
    
    print('master_30bb.json.gz: Found $total3BetCount occurrences of 3BET.');
    if (locations.isNotEmpty) {
        print('Sample locations: ${locations.take(10).toList()}');
    }
  }
}
