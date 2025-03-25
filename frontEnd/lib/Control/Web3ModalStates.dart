part of 'WalletConnectControl.dart';

class Web3State {
  const Web3State();
}

class InitializeWeb3MSuccess extends Web3State {
  const InitializeWeb3MSuccess({required this.service});

  final ReownAppKitModal service;
}

class InitializeWeb3MFailed extends Web3State {}

class WalletConnectionLoading extends Web3State {
  WalletConnectionLoading();
}

class WalletConnectionSuccess extends Web3State {
  const WalletConnectionSuccess();
}

class WalletDisconnectionSuccess extends Web3State {
  const WalletDisconnectionSuccess();
}

class WalletConnectionFailed extends Web3State {
  const WalletConnectionFailed({
    required this.errorCode,
    required this.message,
  });

  final String errorCode;
  final String message;
}

class FetchHomeScreenActionButtonSuccess extends Web3State {
  const FetchHomeScreenActionButtonSuccess({required this.action, this.uid});

  final HomeScreenActionButton action;
  final String? uid;
}
