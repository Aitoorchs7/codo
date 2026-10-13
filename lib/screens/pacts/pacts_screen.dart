import 'package:codo/models/pact.dart';
import 'package:codo/repositories/pact_repository.dart';
import 'package:flutter/material.dart';

class PactsScreen extends StatefulWidget {
  const PactsScreen({super.key});

  @override
  State<PactsScreen> createState() => _PactsScreenState();
}

class _PactsScreenState extends State<PactsScreen> {
  final _repository = PactRepository();
  late Stream<List<Pact>> _pacts;

  @override
  void initState() {
    super.initState();
    _pacts = _repository.watchPacts();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<List<Pact>>(
        stream: _pacts,
        builder: (context, snapshot) {
          if(snapshot.hasError){
            return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                Text('No se pudieron cargar los pactos.'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        _pacts = _repository.watchPacts();
                      });
                    },
                    child: const Text('Reintentar'),
                  )
                ],
            );
          }else if(snapshot.connectionState == ConnectionState.waiting){
            return const CircularProgressIndicator();
          }else if(snapshot.data!.isEmpty){
            return const Text('Todavía no hay pactos.');
          }else if(snapshot.hasData) {
            ListView.builder(itemCount: pacts.length, itemBuilder:);
          }
        },
      ),
    );
  }
}

class _PactCard extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        title: Text(pact.partnerName),
        subtitle: Text("${pact.daysDone}/${pact.daysTotal} días"),
        padding: ,
        child: ListTile(),
      )
    );
  }
  
}