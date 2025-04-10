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

class InvestmentFailed extends Web3State {
  const InvestmentFailed({required this.errorCode, required this.message});

  final String errorCode;
  final String message;
}

class InvestmentSuccess extends Web3State {
  const InvestmentSuccess({
    required this.transactionHash,
    required this.projectAddress,
  });

  final String transactionHash;
  final String projectAddress;
}

class FetchHomeScreenActionButtonSuccess extends Web3State {
  const FetchHomeScreenActionButtonSuccess({required this.action, this.uid});

  final HomeScreenActionButton action;
  final String? uid;
}

class ProjectSubmissionInProgress extends Web3State {
  const ProjectSubmissionInProgress();
}

class ProjectSubmissionSuccess extends Web3State {
  const ProjectSubmissionSuccess();
}

class ProjectSubmissionFailed extends Web3State {
  final String message;
  const ProjectSubmissionFailed({required this.message});
}

class FetchTokenPriceInUSDSuccess extends Web3State {
  const FetchTokenPriceInUSDSuccess({required this.priceList});

  final List<String> priceList;
}
