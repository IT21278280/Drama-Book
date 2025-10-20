import 'package:flutter/material.dart';

class SeatSelector extends StatefulWidget {
  final Function(List<String>) onSeatsChanged;

  const SeatSelector({
    super.key,
    required this.onSeatsChanged,
  });

  @override
  _SeatSelectorState createState() => _SeatSelectorState();
}

class _SeatSelectorState extends State<SeatSelector> {
  List<String> selectedSeats = [];

  final List<String> rows = ['A', 'B', 'C', 'D', 'E', 'F'];
  final List<int> columns = [1, 2, 3, 4, 5, 6, 7, 8];

  void _toggleSeat(String seat) {
    setState(() {
      if (selectedSeats.contains(seat)) {
        selectedSeats.remove(seat);
      } else {
        selectedSeats.add(seat);
      }
    });
    widget.onSeatsChanged(selectedSeats);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Screen indicator
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'SCREEN',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Seat grid
        Column(
          children: rows.map((row) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Row label
                SizedBox(
                  width: 30,
                  child: Text(
                    row,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),

                // Seats in this row
                ...columns.map((col) {
                  final seat = '$row$col';
                  final isSelected = selectedSeats.contains(seat);
                  
                  return Padding(
                    padding: const EdgeInsets.all(2),
                    child: GestureDetector(
                      onTap: () => _toggleSeat(seat),
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? Theme.of(context).primaryColor 
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isSelected 
                                ? Theme.of(context).primaryColor 
                                : Colors.grey[400]!,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            col.toString(),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            const Text('Available'),
            const SizedBox(width: 24),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            const Text('Selected'),
          ],
        ),
      ],
    );
  }
}