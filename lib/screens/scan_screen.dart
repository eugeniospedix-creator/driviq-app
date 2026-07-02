import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/premium_shell.dart';
import '../widgets/digital_twin.dart';
import 'scan_running_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final make = TextEditingController(text: 'BMW');
  final model = TextEditingController(text: 'M340i xDrive');
  final year = TextEditingController(text: '2021');
  bool loaded = true;
  @override
  Widget build(BuildContext context) => DQPage(child: ListView(padding: const EdgeInsets.fromLTRB(22,18,22,120), children: [
    const SectionHeader(title: 'Smart Scan', subtitle: 'Load the vehicle profile before component analysis.'),
    const SizedBox(height: 22),
    GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Vehicle Passport', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
      const SizedBox(height: 16),
      _field(make,'Make'), const SizedBox(height:10), _field(model,'Model'), const SizedBox(height:10), _field(year,'Year'),
      const SizedBox(height: 16),
      DQButton(label:'LOAD VERIFIED PROFILE', dark: true, onTap:()=>setState(()=>loaded=true)),
    ])),
    const SizedBox(height: 18),
    DarkPanel(child: Column(children: [
      const SizedBox(height: 240, child: DigitalTwin(dark:true, interactive:false)),
      Text(loaded ? 'Digital Twin Ready' : 'Waiting for profile', style: const TextStyle(color:Colors.white,fontSize:25,fontWeight:FontWeight.w900)),
      const SizedBox(height: 8),
      Text(loaded ? '${make.text} ${model.text} ${year.text} prepared for acoustic + structural scan.' : 'Insert vehicle details to prepare analysis.', textAlign:TextAlign.center, style: const TextStyle(color:Colors.white54,height:1.35)),
    ])),
    const SizedBox(height: 18),
    DQButton(label:'START COMPONENT SCAN', onTap: loaded ? ()=>Navigator.push(context, MaterialPageRoute(builder:(_)=>const ScanRunningScreen())) : null),
  ]));
  Widget _field(TextEditingController c, String label)=>TextField(controller:c, decoration:InputDecoration(labelText:label,filled:true,fillColor:DQ.ice,border:OutlineInputBorder(borderRadius:BorderRadius.circular(22),borderSide:BorderSide.none)));
}
