import 'dart:async';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:paybox_app/features/home/providers/home_provider.dart';
import 'package:bombotickets/features/tickets/qr/providers/qr_form_provider.dart';
import 'package:bombotickets/features/tickets/qr/repositories/qr_repository.dart';

class QrPaymentProcessState {
  final bool isLoading;
  final String? qrImage;
  final String? qrId;
  final String? errorMessage;
  final double? amount;
  final bool isPaymentConfirmed;
  final int? quantity;
  final double? remainingAmount;
  final bool allPaymentsCompleted;
  final bool isManualCheckLoading;
  final String? manualCheckMessage;
  final int manualCheckMessageId;
  final String? nombreEvento;
  final String? nombreZona;
  final String? correoVendedor;
  final int? publicacionId;

  QrPaymentProcessState({
    this.isLoading = false,
    this.qrImage,
    this.qrId,
    this.errorMessage,
    this.amount,
    this.isPaymentConfirmed = false,
    this.quantity,
    this.remainingAmount,
    this.allPaymentsCompleted = false,
    this.isManualCheckLoading = false,
    this.manualCheckMessage,
    this.manualCheckMessageId = 0,
    this.nombreEvento,
    this.nombreZona,
    this.correoVendedor,
    this.publicacionId,
  });

  QrPaymentProcessState copyWith({
    bool? isLoading,
    String? qrImage,
    String? qrId,
    String? errorMessage,
    double? amount,
    bool? isPaymentConfirmed,
    int? cantidad,
    double? remainingAmount,
    bool? allPaymentsCompleted,
    bool? isManualCheckLoading,
    String? manualCheckMessage,
    int? manualCheckMessageId,
  }) {
    return QrPaymentProcessState(
      isLoading: isLoading ?? this.isLoading,
      qrImage: qrImage ?? this.qrImage,
      qrId: qrId ?? this.qrId,
      errorMessage: errorMessage ?? this.errorMessage,
      amount: amount ?? this.amount,
      isPaymentConfirmed: isPaymentConfirmed ?? this.isPaymentConfirmed,
      quantity: quantity ?? this.quantity,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      allPaymentsCompleted: allPaymentsCompleted ?? this.allPaymentsCompleted,
      isManualCheckLoading: isManualCheckLoading ?? this.isManualCheckLoading,
      manualCheckMessage: manualCheckMessage ?? this.manualCheckMessage,
      manualCheckMessageId: manualCheckMessageId ?? this.manualCheckMessageId,
    );
  }
}

class QrPaymentProcessNotifier extends StateNotifier<QrPaymentProcessState> {
  final Ref ref;
  final QrRepository qrRepository;
  Timer? _verificationTimer;

  QrPaymentProcessNotifier(this.ref, {required this.qrRepository})
    : super(QrPaymentProcessState());

  @override
  void dispose() {
    _verificationTimer?.cancel();
    super.dispose();
  }

  Future<void> generateQRForCurrentPayer() async {
    try {
      final qrForm = ref.read(qrFormProvider);
      final currentAmount = qrForm.currentAmount;
      final porcentaje = qrForm.tipPercentage;
      final bolivianos = qrForm.tipBolivianos;
      final paso = qrForm.currentPayerIndex;
      final cantidad = qrForm.quantity;
      final additionalData = qrForm.additionalData;

      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        isPaymentConfirmed: false,
      );

      final qrData = await qrRepository.generateQR(
        monto: currentAmount,
        porcentaje: porcentaje,
        bolivianos:
            bolivianos ,
        cantidad: cantidad,
        additionalData: additionalData,
         nombreEvento: qrForm.nombreEvento,
      nombreZona: qrForm.nombreZona,
      correoVendedor: qrForm.correoVendedor,
      publicacionId: qrForm.publicacionId,
      );

      state = state.copyWith(
        isLoading: false,
        qrImage: qrData['qrImage'],
        qrId: qrData['qrId'],
        amount: qrData['amount'],
        cantidad: qrForm.quantity,
      );

      // Iniciar verificación solo si no está ya en progreso
      if (_verificationTimer == null || !_verificationTimer!.isActive) {
        _startPaymentVerification();
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void _startPaymentVerification() {
    _verificationTimer?.cancel();
    _verificationTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (state.isPaymentConfirmed || state.qrId == null) {

        _verificationTimer?.cancel();
        return;
      }else{

      }

      await _checkPaymentStatus();
    });
  }
  Future<void> _mandarInfo() async {
    final id = state.qrId;
    if (id == null) return;
    try {
      final detalles = await qrRepository.getQrDetalles(id);
      log('QR DETALLES RECIBIDOS: $detalles');
    } catch (e) {
      log('Error al obtener detalles de QR: $e');
    }
  }

  Future<void> _checkPaymentStatus() async {
    try {
      // No actualizamos isLoading para evitar parpadeos
      final status = await qrRepository.checkStatusQR(state.qrId!);

      if (status == 'PAG') {
        final qrFormNotifier = ref.read(qrFormProvider.notifier);
        qrFormNotifier.markCurrentAsPaid();
          try {
        final detalles = await qrRepository.getQrDetalles(state.qrId!);
        log('QR DETALLES OK => $detalles');
      } catch (e) {
        log('QR DETALLES ERROR => $e');
      }

        // Calcular monto restante correctamente
        final qrFormState = ref.read(qrFormProvider);
        double remaining = 0.0;

        // Sumar solo los montos de los pagadores restantes
        for (
          int i = qrFormState.currentPayerIndex + 1;
          i < qrFormState.qrAmounts.length;
          i++
        ) {
          remaining += qrFormState.qrAmounts[i];
        }
//aqui mando id qr a mi back
        state = state.copyWith(
          isPaymentConfirmed: true,
          remainingAmount: remaining,
          allPaymentsCompleted: qrFormState.isPaymentComplete,
        );

        // Cancelar el timer ya que el pago se confirmó
        _verificationTimer?.cancel();
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> manualCheckPaymentStatus() async {
    // No permitir consulta manual si ya está verificando automáticamente o si ya se confirmó
    if (state.isManualCheckLoading ||
        state.isPaymentConfirmed ||
        state.qrId == null
    //|| (_verificationTimer?.isActive ?? false)
    ) {
      log("Consulta manual no permitida en este momento.");
      return;
    }

    try {
      state = state.copyWith(
        isManualCheckLoading: true,
        manualCheckMessage: null,
        manualCheckMessageId: state.manualCheckMessageId + 1,
      );

      final status = await qrRepository.checkStatusQR(state.qrId!);

      if (status == 'PAG') {
        final qrFormNotifier = ref.read(qrFormProvider.notifier);
        qrFormNotifier.markCurrentAsPaid();

          try {
        final detalles = await qrRepository.getQrDetalles(state.qrId!);
        log('QR DETALLES OK => $detalles');
      } catch (e) {
        log('QR DETALLES ERROR => $e');
      }

        // Calcular monto restante correctamente
        final qrFormState = ref.read(qrFormProvider);
        double remaining = 0.0;

        // Sumar solo los montos de los pagadores restantes
        for (
          int i = qrFormState.currentPayerIndex + 1;
          i < qrFormState.qrAmounts.length;
          i++
        ) {
          remaining += qrFormState.qrAmounts[i];
        }

        state = state.copyWith(
          isManualCheckLoading: false,
          isPaymentConfirmed: true,
          remainingAmount: remaining,
          allPaymentsCompleted: qrFormState.isPaymentComplete,
          manualCheckMessage: '¡Pago confirmado exitosamente!',
          manualCheckMessageId: state.manualCheckMessageId + 1,
        );

        // Cancelar el timer automático ya que el pago se confirmó
        _verificationTimer?.cancel();
      } else {
        state = state.copyWith(
          isManualCheckLoading: false,
          manualCheckMessage: 'El pago aún está pendiente. Intenta nuevamente.',
          manualCheckMessageId: state.manualCheckMessageId + 1,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isManualCheckLoading: false,
        manualCheckMessage: 'Error al consultar estado: ${e.toString()}',
        manualCheckMessageId: state.manualCheckMessageId + 1,
      );
    }
  }

  void clearManualCheckMessage() {
    state = state.copyWith(manualCheckMessage: null);
  }

  void moveToNextPayer() {
    state = state.copyWith(
      isPaymentConfirmed: false,
      qrImage: null,
      qrId: null,
    );
    showState();
  }

  void reset() {
    _verificationTimer?.cancel();
    state = QrPaymentProcessState();
  }

  void showState() {
    log("isLoading: ${state.isLoading}");
    log("qrImage: ${state.qrImage}");
    log("qrId: ${state.qrId}");
    log("errorMessage: ${state.errorMessage}");
    log("amount: ${state.amount}");
    log("isPaymentConfirmed: ${state.isPaymentConfirmed}");
    log("tableId: ${state.quantity}");
    log("remainingAmount: ${state.remainingAmount}");
    log("allPaymentsCompleted: ${state.allPaymentsCompleted}");
  }
}

final qrPaymentProcessProvider =
    StateNotifierProvider<QrPaymentProcessNotifier, QrPaymentProcessState>((
      ref,
    ) {
      return QrPaymentProcessNotifier(
        ref,
        qrRepository: ref.read(qrRepositoryProvider),
      );
    });
