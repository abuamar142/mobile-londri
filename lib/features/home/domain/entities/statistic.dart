import 'package:equatable/equatable.dart';

class Statistic extends Equatable {
  final double todayRevenue;
  final int onProgressCount;
  final int readyForPickupCount;
  final int pickedUpCount;

  const Statistic({
    required this.todayRevenue,
    required this.onProgressCount,
    required this.readyForPickupCount,
    required this.pickedUpCount,
  });

  @override
  List<Object> get props => [
        todayRevenue,
        onProgressCount,
        readyForPickupCount,
        pickedUpCount,
      ];
}
