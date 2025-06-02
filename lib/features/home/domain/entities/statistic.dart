import 'package:equatable/equatable.dart';

class Statistic extends Equatable {
  final int last3DaysRevenue;
  final int onProgressCount;
  final int readyForPickupCount;
  final int pickedUpCount;

  const Statistic({
    required this.last3DaysRevenue,
    required this.onProgressCount,
    required this.readyForPickupCount,
    required this.pickedUpCount,
  });

  @override
  List<Object> get props => [
        last3DaysRevenue,
        onProgressCount,
        readyForPickupCount,
        pickedUpCount,
      ];
}
