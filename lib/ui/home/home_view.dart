import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import '../../controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:invernadero/controllers/ia_control_controller.dart';
import 'package:invernadero/controllers/dashboard_controller.dart';
import 'package:invernadero/controllers/sensor_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final authController = Get.find<AuthController>();
  final Random _random = Random();
  Timer? _timer;

  // Datos simulados
  double _currentTemperature = 24.5;
  String _systemStatus = 'Óptimo';
  String _lastReading = 'hace 2 min';
  String _aiMode = 'Automático';
  double _averageTemperature = 23.8;
  double _yesterdayVariation = 0.7;
  double _sensorAccuracy = 99.2;
  double _aiEfficiency = 94.5;

  // Datos para el gráfico (últimas 24 horas)
  List<FlSpot> _temperatureData = [];

  @override
  void initState() {
    super.initState();
    _generateHistoricalData();
    _startTemperatureSimulation();
    
    // Cargar datos de los controladores (solo si están disponibles)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final context = Get.context;
        if (context != null) {
          final sensorController = Provider.of<SensorController>(context, listen: false);
          sensorController.load();
        }
      } catch (e) {
        // Los controladores aún no están disponibles, ignorar
        print('Controladores no disponibles aún: $e');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _generateHistoricalData() {
    final now = DateTime.now();
    _temperatureData = List.generate(24, (index) {
      final hour = now.subtract(Duration(hours: 23 - index));
      // Temperatura simulada con variación natural
      final baseTemp = 24.0 + (_random.nextDouble() - 0.5) * 6;
      return FlSpot(
        index.toDouble(),
        baseTemp,
      );
    });
  }

  void _startTemperatureSimulation() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        // Simular cambios de temperatura realistas
        final change = (_random.nextDouble() - 0.5) * 2.0;
        _currentTemperature = (_currentTemperature + change).clamp(18.0, 32.0);
        
        // Actualizar estado del sistema
        if (_currentTemperature >= 22 && _currentTemperature <= 26) {
          _systemStatus = 'Óptimo';
        } else if (_currentTemperature >= 20 && _currentTemperature <= 28) {
          _systemStatus = 'Alerta';
        } else {
          _systemStatus = 'Crítico';
        }

        // Actualizar última lectura
        _lastReading = 'hace ${_random.nextInt(3) + 1} min';

        // Actualizar gráfico (mover datos hacia la izquierda)
        _temperatureData.removeAt(0);
        _temperatureData.add(FlSpot(23, _currentTemperature));

        // Actualizar otros datos simulados
        _averageTemperature = (_averageTemperature + (_random.nextDouble() - 0.5) * 0.2).clamp(20.0, 28.0);
        _yesterdayVariation = (_random.nextDouble() - 0.5) * 1.5;
        _sensorAccuracy = (98.5 + _random.nextDouble() * 1.5).clamp(98.0, 100.0);
        _aiEfficiency = (92.0 + _random.nextDouble() * 8.0).clamp(90.0, 100.0);
      });
    });
  }

  Color _getTemperatureColor() {
    if (_currentTemperature >= 22 && _currentTemperature <= 26) {
      return Colors.green;
    } else if (_currentTemperature >= 20 && _currentTemperature <= 28) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Color _getStatusColor() {
    switch (_systemStatus) {
      case 'Óptimo':
        return Colors.green;
      case 'Alerta':
        return Colors.orange;
      case 'Crítico':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getAiModeColor() {
    switch (_aiMode) {
      case 'Automático':
        return const Color(0xFF00BCD4); // cyan como en login
      case 'Manual':
        return const Color(0xFF1565C0); // azul como AppBar/perfil
      case 'Híbrido':
        return const Color(0xFF00B4D8); // cyan claro/acento
      default:
        return Colors.grey;
    }
  }

  void _changeAiMode(String mode) {
    setState(() {
      _aiMode = mode;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Modo IA cambiado a: $mode'),
        backgroundColor: _getAiModeColor(),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildDemoBanner(BuildContext context) {
    return Consumer<SensorController>(
      builder: (context, controller, _) {
        if (controller.error?.contains('demostración') == true) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200, width: 2),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber.shade800, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📡 Modo Demostración',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.amber.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mostrando datos simulados. El sistema está funcionando en modo offline.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Invernadero Upc IA',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [

          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => Get.toNamed('/profile'),
            tooltip: 'Mi perfil',
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _systemStatus,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authController.signOut();
              Get.offAllNamed('/login');
            },
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner de modo demostración
            _buildDemoBanner(context),
            const SizedBox(height: 16),
            // Encabezado
            _buildHeader(),
            const SizedBox(height: 20),
            
            // Panel principal de temperatura
            _buildTemperaturePanel(),
            const SizedBox(height: 20),
            
            // Gráfica de tendencias
            _buildTrendChart(),
            const SizedBox(height: 20),
            
            // Estado del sistema IA
            _buildAiControls(),
            const SizedBox(height: 20),
            

            
            // Tarjetas informativas
            _buildInfoCards(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF2196F3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.thermostat,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sistema de Control Inteligente',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Última lectura: $_lastReading',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _systemStatus,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemperaturePanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Temperatura Actual',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTemperatureColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Rango: 22-26°C',
                  style: TextStyle(
                    color: _getTemperatureColor(),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${_currentTemperature.toStringAsFixed(1)}°C',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: _getTemperatureColor(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Indicador visual tipo termómetro
                    Container(
                      width: 20,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: ((_currentTemperature - 18) / 14) * 120,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _getTemperatureColor(),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 40,
                      color: Color(0xFF1565C0),
                    ),
                    const SizedBox(height: 8),
                    Consumer<IAControlController>(
                      builder: (context, controller, _) {
                        final modo = controller.control?.modo ?? _aiMode.toLowerCase();
                        String display;
                        Color color;
                        switch (modo) {
                          case 'automatico':
                            display = 'Automático';
                            color = const Color(0xFF00BCD4);
                            break;
                          case 'manual':
                            display = 'Manual';
                            color = const Color(0xFF1565C0);
                            break;
                          case 'hibrido':
                            display = 'Híbrido';
                            color = const Color(0xFF00B4D8);
                            break;
                          default:
                            display = _aiMode;
                            color = Colors.grey;
                        }
                        return Column(
                          children: [
                            Text(
                              'IA Activa',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Modo: ' + display,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart() {
    final width = MediaQuery.of(context).size.width;
    final bool isSmall = width < 380;
    final bool isMedium = width >= 380 && width < 480;
    final bool isTiny = width < 330;
    final double chartWidth = isTiny ? 380 : double.infinity;
    final double chartHeight = isSmall ? 300 : (isMedium ? 280 : 320);
    final double labelFont = isSmall ? 12 : 13;
    final double leftReserved = isSmall ? 46 : 50;
    final double bottomReserved = isSmall ? 32 : 36;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.show_chart,
                color: Color(0xFF1565C0),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Tendencia de Temperatura (24h)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: chartWidth,
              height: chartHeight,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 2,
                    verticalInterval: 2,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: bottomReserved,
                        interval: 4,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final style = TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: labelFont,
                          );
                          Widget text;
                          switch (value.toInt()) {
                            case 0:
                              text = Text('00:00', style: style);
                              break;
                            case 6:
                              text = Text('06:00', style: style);
                              break;
                            case 12:
                              text = Text('12:00', style: style);
                              break;
                            case 18:
                              text = Text('18:00', style: style);
                              break;
                            case 23:
                              text = Text('23:00', style: style);
                              break;
                            default:
                              text = Text('', style: style);
                              break;
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: text,
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            '${value.toInt()}°C',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: labelFont,
                            ),
                          );
                        },
                        reservedSize: leftReserved,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  minX: 0,
                  maxX: 23,
                  minY: 18,
                  maxY: 32,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _temperatureData,
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.shade400,
                          Colors.orange.shade400,
                        ],
                      ),
                      barWidth: isSmall ? 3 : 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: false,
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.red.shade400.withOpacity(0.25),
                            Colors.orange.shade400.withOpacity(0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.psychology,
                color: Color(0xFF1565C0),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Control de IA',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Color(0xFF1565C0)),
                    const SizedBox(width: 8),
                    Consumer<IAControlController>(
                      builder: (context, controller, _) {
                        final modo = controller.control?.modo ?? _aiMode;
                        return Text(
                          'Modo actual: ' + modo,
                          style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w600),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Get.toNamed('/ia-control'),
                  icon: const Icon(Icons.tune),
                  label: const Text('Abrir Control de IA'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 46),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(String title, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? _getAiModeColor() : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _getAiModeColor() : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildInfoCard(
          'Temperatura Promedio',
          '${_averageTemperature.toStringAsFixed(1)}°C',
          Icons.thermostat_outlined,
          const Color(0xFF1565C0),
        ),
        _buildInfoCard(
          'Variación vs Ayer',
          '${_yesterdayVariation > 0 ? '+' : ''}${_yesterdayVariation.toStringAsFixed(1)}°C',
          Icons.trending_up,
          _yesterdayVariation > 0 ? Colors.red : Colors.green,
        ),
        _buildInfoCard(
          'Precisión Sensor',
          '${_sensorAccuracy.toStringAsFixed(1)}%',
          Icons.precision_manufacturing,
          const Color(0xFF00B4D8),
        ),
        _buildInfoCard(
          'Eficiencia IA',
          '${_aiEfficiency.toStringAsFixed(1)}%',
          Icons.auto_awesome,
          const Color(0xFF00BCD4),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}