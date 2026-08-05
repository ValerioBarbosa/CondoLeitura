import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/meter.dart';
import '../../models/reading.dart';
import '../../models/unit.dart';
import '../../repositories/local/local_reading_repository.dart';
import '../../services/camera_service.dart';
import '../../services/file_storage_service.dart';
import '../../services/ocr_service.dart';

class CaptureReadingScreen extends StatefulWidget {
  const CaptureReadingScreen({super.key,required this.unit,required this.meter});
  final Unit unit; final Meter meter;
  @override State<CaptureReadingScreen> createState()=>_CaptureReadingScreenState();
}
class _CaptureReadingScreenState extends State<CaptureReadingScreen>{
  final _camera=CameraService(); final _ocr=OcrService(); final _storage=FileStorageService(); final _repo=LocalReadingRepository();
  final _value=TextEditingController(); final _notes=TextEditingController();
  String? _imagePath,_raw; double? _confidence; bool _busy=false,_manual=false;
  @override void dispose(){_value.dispose();_notes.dispose();super.dispose();}
  Future<void> _choose(bool camera) async { final file=camera?await _camera.capture():await _camera.pickFromGallery(); if(file==null)return; setState((){_busy=true;_imagePath=file.path;}); try{ final r=await _ocr.recognize(imagePath:file.path,integerDigits:widget.meter.integerDigits,decimalDigits:widget.meter.decimalDigits); _raw=r.rawText;_confidence=r.confidence;if(r.value!=null)_value.text=r.value!.toStringAsFixed(widget.meter.decimalDigits);_manual=r.requiresReview; }catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Falha no OCR: $e')));}finally{if(mounted)setState(()=>_busy=false);} }
  Future<void> _save() async { final meterId=widget.meter.id,unitId=widget.unit.id,val=double.tryParse(_value.text.replaceAll(',','.')); if(meterId==null||unitId==null||_imagePath==null||val==null){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Capture a foto e informe uma leitura válida.')));return;} setState(()=>_busy=true); try{ final localId=const Uuid().v4(); final stored=await _storage.persistReadingPhoto(sourcePath:_imagePath!,meterId:meterId,localId:localId); await _repo.insert(Reading(localId:localId,unitId:unitId,meterId:meterId,value:val,readingDate:DateTime.now(),photoPath:stored,ocrRawText:_raw,ocrConfidence:_confidence,requiresReview:(_confidence??0)<0.8,confirmedManually:_manual,notes:_notes.text.trim().isEmpty?null:_notes.text.trim(),createdAt:DateTime.now())); if(mounted)Navigator.pop(context,true); }catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Não foi possível salvar: $e')));}finally{if(mounted)setState(()=>_busy=false);} }
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Capturar leitura')),body:ListView(padding:const EdgeInsets.all(20),children:[
    Card(child:ListTile(leading:Icon(widget.meter.type==MeterType.water?Icons.water_drop:Icons.local_fire_department),title:Text('Unidade ${widget.unit.number}'),subtitle:Text('${widget.meter.type.label} • ${widget.meter.serialNumber}'))),const SizedBox(height:16),
    AspectRatio(aspectRatio:4/3,child:Card(clipBehavior:Clip.antiAlias,child:_imagePath==null?const Center(child:Column(mainAxisSize:MainAxisSize.min,children:[Icon(Icons.camera_alt_outlined,size:64),SizedBox(height:8),Text('Fotografe o visor do medidor')])):Image.file(File(_imagePath!),fit:BoxFit.cover))),
    const SizedBox(height:12),Row(children:[Expanded(child:FilledButton.icon(onPressed:_busy?null:()=>_choose(true),icon:const Icon(Icons.camera_alt),label:const Text('Câmera'))),const SizedBox(width:10),Expanded(child:OutlinedButton.icon(onPressed:_busy?null:()=>_choose(false),icon:const Icon(Icons.photo_library_outlined),label:const Text('Galeria')))]),
    if(_busy)...[const SizedBox(height:16),const LinearProgressIndicator()],const SizedBox(height:20),
    TextField(controller:_value,keyboardType:const TextInputType.numberWithOptions(decimal:true),onChanged:(_)=>_manual=true,decoration:InputDecoration(labelText:'Leitura confirmada',prefixIcon:const Icon(Icons.pin_outlined),helperText:_confidence==null?'Aguardando OCR':'Confiança OCR: ${(_confidence!*100).round()}%')),
    const SizedBox(height:12),TextField(controller:_notes,maxLines:3,decoration:const InputDecoration(labelText:'Observações',prefixIcon:Icon(Icons.notes))),
    if((_raw??'').isNotEmpty)...[const SizedBox(height:12),ExpansionTile(title:const Text('Texto bruto reconhecido'),children:[Padding(padding:const EdgeInsets.all(12),child:SelectableText(_raw!))])],
    const SizedBox(height:24),FilledButton.icon(onPressed:_busy?null:_save,icon:const Icon(Icons.save),label:const Text('Confirmar e salvar leitura')),
  ]));
}
