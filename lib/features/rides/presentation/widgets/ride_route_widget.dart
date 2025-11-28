import 'package:flutter/material.dart';

class RideRouteWidget extends StatelessWidget {
  final String pickupAddress;
  final String destinationAddress;
  final TextStyle? style;

  const RideRouteWidget({
    super.key,
    required this.pickupAddress,
    required this.destinationAddress,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = style ?? Theme.of(context).textTheme.bodyMedium;
    
    return Text.rich(
      TextSpan(
        style: textStyle,
        children: [
          TextSpan(text: pickupAddress),
          const WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
            ),
          ),
          TextSpan(text: destinationAddress),
        ],
      ),
    );
  }
}
