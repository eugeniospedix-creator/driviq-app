import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/premium_shell.dart';

class SettingsScreen extends StatelessWidget { const SettingsScreen({super.key}); @override Widget build(BuildContext context)=>DQPage(child:ListView(padding:const EdgeInsets.fromLTRB(22,18,22,120),children:[
  const SectionHeader(title:'Settings', subtitle:'Privacy, sensors and vehicle intelligence.'),
  const SizedBox(height:22),
  _tile(Icons.mic_rounded,'Microphone','Local audio analysis. Temporary files deleted after scan.'),
  _tile(Icons.screen_rotation_alt_rounded,'Motion Sensors','Accelerometer and gyroscope vibration profile.'),
  _tile(Icons.shield_rounded,'Privacy Mode','Do not store raw cabin audio.'),
  _tile(Icons.drive_eta_rounded,'Safe Driving Mode','Reduce interaction while the vehicle is moving.'),
  _tile(Icons.workspace_premium_rounded,'Driviq Plus','Advanced reports, export and future OBD-II support.'),
]));
Widget _tile(IconData i,String t,String s)=>Padding(padding:const EdgeInsets.only(bottom:14),child:GlassPanel(child:Row(children:[Icon(i,color:DQ.cyan,size:32),const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(t,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900)),const SizedBox(height:4),Text(s,style:const TextStyle(color:DQ.muted,height:1.3))])),const Icon(Icons.chevron_right_rounded,color:DQ.muted)])));
}
