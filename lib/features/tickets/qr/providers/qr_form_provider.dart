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
  final String? nombreEvento;
  final String? nombreZona;
  final String? correoVendedor;
  final int? publicacionId;

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
      this.nombreEvento,
    this.nombreZona,
    this.correoVendedor,
    this.publicacionId,
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
     String? nombreEvento,
    String? nombreZona,
    String? correoVendedor,
    int? publicacionId,
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
       nombreEvento: nombreEvento ?? this.nombreEvento,
      nombreZona: nombreZona ?? this.nombreZona,
      correoVendedor: correoVendedor ?? this.correoVendedor,
      publicacionId: publicacionId ?? this.publicacionId,
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
  String? nombreEvento,      // ← Nuevo
  String? nombreZona,        // ← Nuevo
  String? correoVendedor,
  int? publicacionId,
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
    nombreEvento: nombreEvento,
    nombreZona: nombreZona,
    correoVendedor: correoVendedor,
    publicacionId: publicacionId,
  );
}

  
   void markCurrentAsPaid() {
    state = state.copyWith(isPaymentComplete: true);
    showState();
  }
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
