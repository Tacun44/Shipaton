import 'package:flutter/material.dart';
import 'config/supabase_config.dart';
import 'services/database_service.dart';
import 'screens/home_screen.dart';
import 'constants/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Supabase
  await SupabaseConfig.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mueve - Tu dinero en movimiento',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.darkNavy),
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightGray,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkNavy,
          foregroundColor: AppColors.pureWhite,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _registrosEnDB = 0;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _cargarRegistrosDB();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  // Cargar registros existentes en la base de datos
  Future<void> _cargarRegistrosDB() async {
    setState(() => _cargando = true);
    
    try {
      final registros = await DatabaseService.obtenerRegistrosPrueba();
      setState(() {
        _registrosEnDB = registros.length;
        _cargando = false;
      });
    } catch (error) {
      print('Error al cargar registros: $error');
      setState(() => _cargando = false);
    }
  }

  // Insertar nuevo registro en Supabase
  Future<void> _insertarEnSupabase() async {
    setState(() => _cargando = true);
    
    try {
      final resultado = await DatabaseService.insertarRegistroPrueba();
      if (resultado != null) {
        await _cargarRegistrosDB(); // Recargar la lista
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Registro insertado en Supabase!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    setState(() => _cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: [
            const Icon(Icons.rocket_launch, color: Colors.blue),
            const SizedBox(width: 8),
            Text(widget.title),
          ],
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Sección del contador local
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Contador Local',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text('Has presionado el botón:'),
                      Text(
                        '$_counter',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Sección de Supabase
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        '🗄️ Conexión Supabase',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _cargando
                          ? const CircularProgressIndicator()
                          : Text(
                              'Registros en DB: $_registrosEnDB',
                              style: const TextStyle(fontSize: 16),
                            ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _cargando ? null : _insertarEnSupabase,
                        icon: const Icon(Icons.add_circle),
                        label: const Text('Insertar en Supabase'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _cargando ? null : _cargarRegistrosDB,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Actualizar'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
