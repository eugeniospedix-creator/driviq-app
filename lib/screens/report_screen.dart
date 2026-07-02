import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/component_status.dart';
import '../widgets/premium_shell.dart';
import '../widgets/digital_twin.dart';

class ReportScreen extends StatefulWidget { const ReportScreen({super.key}); @override State<ReportScreen> createState()=>_ReportScreenState(); }
class _ReportScreenState extends State<ReportScreen> {
  ComponentStatus selected = demoComponents[1];
  @override Widget build(BuildContext context)=>DQPage(child:ListView(padding:const EdgeInsets.fromLTRB(22,18,22,120),children:[
    const SectionHeader(title:'Report', subtitle:'Component-level preliminary interpretation.'),
    const SizedBox(height:22),
    DarkPanel(child:Column(children:[
      SizedBox(height:310,child:DigitalTwin(dark:true,interactive:true,selected:selected,onSelect:(c)=>setState(()=>selected=c))),
      const SizedBox(height:10),
      const Text('Tap a component to inspect',style:TextStyle(color:Colors.white54)),
    ])),
    const SizedBox(height:18),
    GlassPanel(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[Container(width:14,height:14,decoration:BoxDecoration(color:selected.color,shape:BoxShape.circle,boxShadow:[BoxShadow(color:selected.color.withOpacity(.5),blurRadius:18)])),const SizedBox(width:10),Text(selected.zone,style:const TextStyle(color:DQ.muted,fontWeight:FontWeight.w800))]),
      const SizedBox(height:12),
      Text(selected.name,style:const TextStyle(fontSize:28,fontWeight:FontWeight.w900,letterSpacing:-.7)),
      const SizedBox(height:8),
      Text(selected.finding,style:const TextStyle(color:DQ.muted,height:1.35)),
      const SizedBox(height:22),
      Row(children:[_metric('Confidence','${selected.confidence}%',selected.color),const SizedBox(width:12),_metric('Signal Quality','${selected.signalQuality}%',DQ.cyan)]),
      const SizedBox(height:18),
      Text('Recommendation',style:Theme.of(context).textTheme.titleLarge),
      const SizedBox(height:6),
      Text(selected.recommendation,style:const TextStyle(color:DQ.muted,height:1.4)),
      const SizedBox(height:14),
      const Text('Driviq provides preliminary insights only. Confirm with a qualified mechanic.',style:TextStyle(color:DQ.muted,fontSize:12,height:1.3)),
    ])),
  ]));
  Widget _metric(String a,String b,Color color)=>Expanded(child:Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:DQ.ice,borderRadius:BorderRadius.circular(22)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(a,style:const TextStyle(color:DQ.muted,fontSize:12,fontWeight:FontWeight.w700)),const SizedBox(height:4),Text(b,style:TextStyle(color:color,fontSize:28,fontWeight:FontWeight.w900))])));
}
