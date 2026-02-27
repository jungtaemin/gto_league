import 'dart:convert';
import 'dart:io';

void main() async {
  var baseDir = r'c:\Users\jtm02\Desktop\antigravity\allinfold\holdem_allin_fold\assets\db';
  print('\n=== Analyzing action sequences in master_30bb.json.gz ===');
  var gzFile = File('$baseDir\\master_30bb.json.gz');
  if (await gzFile.exists()) {
    var bytes = await gzFile.readAsBytes();
    var decompressed = gzip.decode(bytes);
    var content = utf8.decode(decompressed);
    
    dynamic data = jsonDecode(content);
    
    if (data is Map && data.containsKey('nodes')) {
         Map<String, dynamic> nodes = data['nodes'];
         List<String> keys = nodes.keys.toList();
         
         print('Total node keys: ${keys.length}');
         
         // Let's count occurrences of actions in the node keys
         int foldCount = 0;
         int callCount = 0;
         int raiseCount = 0;
         int allInCount = 0; // "A" usually means All-In
         int otherCount = 0;

         Map<String, int> actionCounts = {};

         for (var key in keys) {
             // Example format: UTG_F.UTG1_F.UTG2_F.LJ_R.HJ_C.CO_R.BTN_F.SB_A.BB_F.LJ_C.HJ_F__CO
             String seqStr = key.split('__').first;
             List<String> actions = seqStr.split('.');
             for (var act in actions) {
                 if (act.contains('_')) {
                    String actionType = act.split('_')[1];
                    actionCounts[actionType] = (actionCounts[actionType] ?? 0) + 1;
                 }
             }
         }
         print('Action counts in sequences: $actionCounts');

         // Let's check the array length and sum for a few entries
         // e.g. {22: [70, 30, 0, 0]}
         int arrayLen = -1;
         Set<int> arraySums = {};
         
         for (int i = 0; i < 50 && i < keys.length; i++) {
             Map<String, dynamic> handMap = nodes[keys[i]];
             if (handMap.isNotEmpty) {
                 dynamic firstValue = handMap.values.first;
                 if (firstValue is List) {
                     arrayLen = firstValue.length;
                     int sum = 0;
                     for (var val in firstValue) {
                         if (val is num) sum += val.toInt();
                     }
                     arraySums.add(sum);
                 }
                 break;
             }
         }
         print('Array length for hands: $arrayLen');
         print('Array sums: $arraySums');
    }
  }
}
