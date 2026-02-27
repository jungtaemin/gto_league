import 'dart:convert';
import 'dart:io';

void main() async {
  var baseDir = r'c:\Users\jtm02\Desktop\antigravity\allinfold\holdem_allin_fold\assets\db';
  print('\n=== Analyzing 3BET sequences in master_30bb.json.gz ===');
  var gzFile = File('$baseDir\\master_30bb.json.gz');
  if (await gzFile.exists()) {
    var bytes = await gzFile.readAsBytes();
    var decompressed = gzip.decode(bytes);
    var content = utf8.decode(decompressed);
    
    dynamic data = jsonDecode(content);
    
    if (data is Map && data.containsKey('nodes')) {
         Map<String, dynamic> nodes = data['nodes'];
         List<String> keys = nodes.keys.toList();
         
         int sequencesWithMultipleRaises = 0;
         int sequencesWithRaiseThenAllIn = 0;
         int maxRaisesInSequence = 0;
         
         List<String> sample3Bets = [];
         
         for (var key in keys) {
             String seqStr = key.split('__').first;
             List<String> actions = seqStr.split('.');
             
             int raiseCount = 0;
             bool hasR = false;
             bool hasAAfterR = false;
             
             for (var act in actions) {
                 if (act.contains('_')) {
                    String actionType = act.split('_')[1];
                    if (actionType == 'R') {
                        raiseCount++;
                        hasR = true;
                    } else if (actionType == 'A' && hasR) {
                        hasAAfterR = true;
                    }
                 }
             }
             
             if (raiseCount > maxRaisesInSequence) {
                 maxRaisesInSequence = raiseCount;
             }
             
             if (raiseCount >= 2) {
                 sequencesWithMultipleRaises++;
                 if (sample3Bets.length < 5) {
                     sample3Bets.add(key);
                 }
             }
             if (hasAAfterR) {
                 sequencesWithRaiseThenAllIn++;
             }
         }
         
         print('Total nodes: ${keys.length}');
         print('Sequences with >= 2 Raises (3BET or more): $sequencesWithMultipleRaises');
         print('Sequences with Raise then All-In (3BET All-In): $sequencesWithRaiseThenAllIn');
         print('Max raises in a single sequence: $maxRaisesInSequence');
         print('Sample sequences with >= 2 Raises:');
         for (var s in sample3Bets) {
             print(' - $s');
         }
    }
  }
}
