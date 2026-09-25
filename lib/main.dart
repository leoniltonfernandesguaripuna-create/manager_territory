import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'cloud.dart';
import 'tema.dart';     
import 'stores.dart';
import 'widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Cloud.iniciar();
  await _carregarDados();
  runApp(const TerritorioApp());
}

Future<void> _carregarDados() async {
  if (!Cloud.disponivel) return;
  try {
    final terr = await Cloud.ler('territorios');
    if (terr != null && terr['lista'] != null) {
      TerritoriosStore.instance.carregar(List<Map<String, dynamic>>.from(
        (terr['lista'] as List).map((e) => Map<String, dynamic>.from(e)),
      ));
    }
    final desig = await Cloud.ler('designacoes');
    if (desig != null && desig['dados'] != null) {
      DesignacaoStore.instance.carregar(Map<String, dynamic>.from(desig['dados']));
    }
    final obs = await Cloud.ler('observacoes');
    if (obs != null && obs['dados'] != null) {
      ObsStore.instance.carregar(Map<String, dynamic>.from(obs['dados']));
    }
    final dir = await Cloud.ler('dirigentes');
    if (dir != null && dir['nomes'] != null) {
      final nomesMap = Map<String, dynamic>.from(dir['nomes'] as Map);
      final lista = List<List<String>>.generate(
        3,
        (i) => List<String>.from(nomesMap['$i'] ?? []),
      );
      DirigentesStore.carregar(lista);
    }
    final adm = await Cloud.ler('admins');
    if (adm != null && adm['senhas'] != null) {
      AuthStore.instance.carregarAdmins(Map<String, String>.from(adm['senhas']));
    }
    final sc = await Cloud.ler('servico_campo');
    if (sc != null && sc['locais'] != null) {
      ServicoCampoStore.instance.carregar(Map<String, dynamic>.from(sc['locais']));
    }
    final ev = await Cloud.ler('eventos');
    if (ev != null && ev['dados'] != null) {
      EventosStore.instance.carregar(Map<String, dynamic>.from(ev['dados']));
    }
    final mapas = await Cloud.ler('mapas');
    if (mapas != null) {
      MapasStore.carregar(mapas);
    }
    final quadras = await Cloud.ler('quadras');
    if (quadras != null) {
      QuadrasStore.carregar(quadras);
    }
    final dirTerr = await Cloud.ler('dirigentes_territorio');
    if (dirTerr != null) {
      DirigenteTerritorioStore.carregar(dirTerr);
    }
  } catch (_) {}
}

class TerritorioApp extends StatelessWidget {
  const TerritorioApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Território de Congregação',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
        fontFamily: 'Roboto',
      ),
      home: const HomePage(),
    );
  }
}


          
                    
            
    
                    
        
                                  
                            

    
                      
                      
              
                          
