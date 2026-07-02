import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/premium_shell.dart';
import '../widgets/digital_twin.dart';

class GarageScreen extends StatelessWidget {
  const GarageScreen({super.key});
  @override Widget build(BuildContext context)=>DQPage(child:ListView(padding:const EdgeInsets.fromLTRB(22,18,22,120),children:[
    const SectionHeader(title:'Garage', subtitle:'A digital vehicle room for every car you own.'),
    const SizedBox(height:22),
    _vehicle('BMW M340i xDrive','Excellent','98',DQ.emerald,true),
    const SizedBox(height:16),
    _vehicle('Audi A3 2.0 TDI','Attention','82',DQ.amber,false),
    const SizedBox(height:16),
    GlassPanel(child: Row(children: const [Icon(Icons.add_circle_rounded,color:DQ.cyan,size:38),SizedBox(width:14),Expanded(child:Text('Add vehicle manually or with VIN lookup.',style:TextStyle(fontWeight:FontWeight.w900)))])),
  ]));
  Widget _vehicle(String name,String state,String score,Color color,bool main)=>DarkPanel(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text(name,style:const TextStyle(color:Colors.white,fontSize:23,fontWeight:FontWeight.w900)),
    const SizedBox(height:8),
    Row(children:[Text(score,style:TextStyle(color:color,fontSize:42,fontWeight:FontWeight.w900)),const SizedBox(width:8),Text(state,style:TextStyle(color:color,fontSize:18,fontWeight:FontWeight.w800))]),
    SizedBox(height:main?220:150,child:const DigitalTwin(dark:true,interactive:false)),
    const Text('Last scan: Today • Vehicle Passport active',style:TextStyle(color:Colors.white54)),
  ]));
}
