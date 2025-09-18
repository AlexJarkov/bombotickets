import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class QrFormState {
  final List<double> qrAmounts;
  final int currentPayerIndex;
  final bool isPaymentComplete;
  final double tipPercentage;        // aquí es la comisión %
  final double tipBolivianos;        // comisión en Bs
  final double tableTotal;           // base total (sin comisión)
  final int quantity;                // cantidad de tickets
  final String additionalData;// ID PARA HEADER DEL GENERAR QR
  //final int splitCount; 

  QrFormState({
    required this.qrAmounts,
    required this.currentPayerIndex,
    required this.isPaymentComplete,
    required this.tipPercentage,
    required this.tipBolivianos,
    required this.tableTotal,
    required this.quantity,
    //required this.splitCount,
    required this.additionalData,
  });

  double get currentAmount =>
      qrAmounts.isNotEmpty ? qrAmounts[currentPayerIndex] : 0.0;

  QrFormState copyWith({
    List<double>? qrAmounts,
    int? currentPayerIndex,
    bool? isPaymentComplete,
    double? tipPercentage,
    double? tipBolivianos,
    double? tableTotal,
    int? tableId,
    int ? quantity,
    //int? splitCount,
    String? additionalData,
  }) {
    return QrFormState(
      qrAmounts: qrAmounts ?? this.qrAmounts,
      currentPayerIndex: currentPayerIndex ?? this.currentPayerIndex,
      isPaymentComplete: isPaymentComplete ?? this.isPaymentComplete,
      tipPercentage: tipPercentage ?? this.tipPercentage,
      tipBolivianos: tipBolivianos ?? this.tipBolivianos,
      tableTotal: tableTotal ?? this.tableTotal,
      quantity: quantity ?? this.quantity,
      //splitCount: splitCount ?? this.splitCount,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}

class QrFormNotifier extends StateNotifier<QrFormState> {
  QrFormNotifier()
    : super(
        QrFormState(
          qrAmounts: [],
          currentPayerIndex: 0,
          isPaymentComplete: false,
          tipPercentage: 0,
          tipBolivianos: 0,
          tableTotal: 0,
          quantity: 0,
          //splitCount: 1,
          additionalData: '',
        ),
      );
void initializeSimple({
  required double baseTotal,
  required double commissionPercent,
  required int quantity,
}) {
  final commissionBs = baseTotal * (commissionPercent / 100.0);
  final grandTotal = baseTotal + commissionBs;
  final additionalData = DateFormat('yyyyMMddHHmmss').format(DateTime.now());

  state = state.copyWith(
    qrAmounts: [grandTotal],     // un solo pago
    currentPayerIndex: 0,
    isPaymentComplete: false,
    tipPercentage: commissionPercent, // aquí guardamos la comisión %
    tipBolivianos: commissionBs,      // comisión en Bs
    tableTotal: baseTotal,            // subtotal sin comisión
    quantity: quantity,               // cantidad de tickets
    additionalData: additionalData,
  );
}

  /*
  void initializePayment(
    double tableTotal,
    int splitCount,
    double tipPercentage,
    int tableId,
  )
  */

   /*
    final subtotal = tableTotal / splitCount;
    final totalTip =
        tableTotal * (tipPercentage / 100); // propina total de la mesa
    final tipPerPerson = totalTip / splitCount; // propina por persona
    final totalWithTip = subtotal + tipPerPerson;
*/
  
   void markCurrentAsPaid() {
    state = state.copyWith(isPaymentComplete: true);
    showState();
  }
/*
  void moveToNextPayer() {
    if (state.currentPayerIndex < state.qrAmounts.length - 1) {
      state = state.copyWith(currentPayerIndex: state.currentPayerIndex + 1);
    }
    showState();
  }
*/
  void reset() {
    state = QrFormState(
      qrAmounts: [],
      currentPayerIndex: 0,
      isPaymentComplete: false,
      tipPercentage: 0,
      tipBolivianos: 0,
      tableTotal: 0,
      quantity: 0,
      //splitCount: 1,
      additionalData: '',
    );
  }

  void showState() {
    log("qrAmount: ${state.qrAmounts.toString()}");
    log("currentPayerIndex: ${state.currentPayerIndex}");
    log("isPaymentComplete: ${state.isPaymentComplete}");
    log("tipPercentage: ${state.tipPercentage}");
    log("tipBolivianos: ${state.tipBolivianos}");
    log("tableTotal: ${state.tableTotal}");
    log("tableId: ${state.quantity}");
    //log("splitCount: ${state.splitCount}");
    log("additionalData: ${state.additionalData}");
  }
}

final qrFormProvider = StateNotifierProvider<QrFormNotifier, QrFormState>((
  ref,
) {
  return QrFormNotifier();
});
