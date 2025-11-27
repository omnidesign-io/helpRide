import 'package:flutter/material.dart';
import 'package:helpride/features/rides/domain/ride_model.dart';

class MapPlaceholderWidget extends StatelessWidget {
  final bool isDriver;
  final List<RideModel> pendingRides; // For drivers to see pins
  final VoidCallback? onUpdateLocation;

  const MapPlaceholderWidget({
    super.key,
    required this.isDriver,
    this.pendingRides = const [],
    this.onUpdateLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: Stack(
        children: [
          // Background Grid (Fake Map)
          CustomPaint(
            size: Size.infinite,
            painter: GridPainter(),
          ),
          
          // User Location Pin (Center)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_pin_circle, size: 48, color: Colors.blue),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
                    ],
                  ),
                  child: const Text('You', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // Pending Ride Pins (Randomly placed for demo)
          if (isDriver)
            ...pendingRides.map((ride) {
              // Deterministic "random" position based on ID hash
              final hashCode = ride.id.hashCode;
              final dx = (hashCode % 300).toDouble() - 150; 
              final dy = ((hashCode ~/ 100) % 300).toDouble() - 150;

              return Align(
                alignment: Alignment.center,
                child: Transform.translate(
                  offset: Offset(dx, dy),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, size: 40, color: Colors.red),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2),
                          ],
                        ),
                        child: Text('#${ride.shortId}', style: const TextStyle(fontSize: 10)),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
