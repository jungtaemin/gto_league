import 'dart:convert';
import 'dart:io';

void main() async {
  var baseDir = r'c:\Users\jtm02\Desktop\antigravity\allinfold\holdem_allin_fold\assets\db';
  print('\n=== Deep structural analysis of master_30bb.json.gz ===');
  var gzFile = File('$baseDir\\master_30bb.json.gz');
  if (await gzFile.exists()) {
    var bytes = await gzFile.readAsBytes();
    var decompressed = gzip.decode(bytes);
    var content = utf8.decode(decompressed);
    
    dynamic data = jsonDecode(content);
    
    if (data is Map) {
         print('Type: Map');
         print('Keys: ${data.keys.toList()}');
         
         if (data.containsKey('meta')) {
             print('meta: ${data['meta']}');
         }
         if (data.containsKey('nodes')) {
             dynamic nodes = data['nodes'];
             if (nodes is List) {
                 print('nodes is List, length: ${nodes.length}');
                 for (int i = 0; i < 3 && i < nodes.length; i++) {
                     print('Node $i: ${nodes[i]}');
                 }
             } else if (nodes is Map) {
                 print('nodes is Map, keys length: ${nodes.keys.length}');
                 List<String> ks = nodes.keys.map((e) => e.toString()).toList();
                 for (int i = 0; i < 5 && i < ks.length; i++) {
                     print('Node key ${ks[i]}: ${nodes[ks[i]]}');
                 }
             } else {
                  print('nodes is something else: ${nodes.runtimeType}');
             }
         }
    }
  }
}
