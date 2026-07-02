import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/premium_shell.dart';
import '../widgets/digital_twin.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => DQPage(
    child: ListView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 120),
      children: [
        Row(children: [
          const Expanded(child: SectionHeader(title: 'DRIVIQ', subtitle: 'Vehicle Intelligence')),
          Container(height: 46,width:46,decoration:BoxDecoration(color:DQ.graphite,borderRadius:BorderRadius.circular(16)),child:const Icon(Icons.auto_awesome_rounded,color:DQ.cyan)),
        ]),
        const SizedBox(height: 22),
        DarkPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('BMW M340i xDrive', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -.5)),
          const SizedBox(height: 4),
          const Text('Vehicle Intelligence Ready', style: TextStyle(color: Colors.white54, fontSize: 15)),
          const SizedBox(height: 10),
          const SizedBox(height: 290, child: DigitalTwin(dark: true, interactive: false)),
          Row(children: const [
            _Score(), SizedBox(width: 14), Expanded(child: _Readiness())
          ]),
          const SizedBox(height: 20),
          DQButton(label: 'SCAN', dark: false),
        ])),
        const SizedBox(height: 18),
        GlassPanel(child: Row(children: const [
          Icon(Icons.psychology_rounded, color: DQ.cyan, size: 34), SizedBox(width: 14),
          Expanded(child: Text('Driviq Neural Engine is learning your vehicle baseline from repeated scans.', style: TextStyle(fontWeight: FontWeight.w800, height: 1.35))),
        ])),
      ],
    ),
  );
}

class _Score extends StatelessWidget { const _Score(); @override Widget build(BuildContext context)=>Container(
  height:105,width:105,decoration:BoxDecoration(shape:BoxShape.circle,border:Border.all(color:DQ.emerald,width:5),boxShadow:[BoxShadow(color:DQ.emerald.withOpacity(.22),blurRadius:22)]),
  child:const Column(mainAxisAlignment:MainAxisAlignment.center,children:[Text('98',style:TextStyle(color:Colors.white,fontSize:32,fontWeight:FontWeight.w900)),Text('Health',style:TextStyle(color:Colors.white54,fontSize:12))]),
);}
class _Readiness extends StatelessWidget { const _Readiness(); @override Widget build(BuildContext context)=>Container(
  padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:Colors.white.withOpacity(.07),borderRadius:BorderRadius.circular(24)),
  child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Excellent',style:TextStyle(color:DQ.emerald,fontSize:22,fontWeight:FontWeight.w900)),SizedBox(height:4),Text('No critical anomaly detected in the latest baseline.',style:TextStyle(color:Colors.white54,height:1.3))]),
);}
