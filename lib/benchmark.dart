import 'file:/home/enery/Documents/aqr/aqr_app/aqr_lib/lib/src/core/bit_writer.dart';
import 'file:/home/enery/Documents/aqr/aqr_app/aqr_lib/old_lib/src/common/bit_array.dart';

void benchmark(String name, Function() action) {
  final stopwatch = Stopwatch()..start();
  action();
  stopwatch.stop();
  print('$name: ${stopwatch.elapsedMicroseconds} µs');
}

void runBenchmarks() {
  const testSizes = [10, 100, 1000, 10000];
  const bitsPerWrite = 3; // Example: Writing in chunks of 5 bits

  for (int size in testSizes) {
    print('\nBenchmark for writing $size bits:');

    benchmark("BitArray", () {
      final bitArray = BitArray();
      for (int i = 0; i < size ~/ bitsPerWrite; i++) {
        bitArray.appendBits(0x666666, bitsPerWrite);
      }
    });

    benchmark("OtherBitWriter", () {
      final bitArray = BitWriter();
      for (int i = 0; i < size ~/ bitsPerWrite; i++) {
        bitArray.addInt(0x666666, bitsPerWrite);
      }
    });

    benchmark("BitWriter", () {
      final bitArray = BitWriter();
      for (int i = 0; i < size ~/ bitsPerWrite; i++) {
        bitArray.addInt(0x666666, bitsPerWrite);
      }
    });
  }
}
