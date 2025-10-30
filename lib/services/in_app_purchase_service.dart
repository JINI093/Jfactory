import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../domain/entities/purchase_entity.dart' as entities;

class InAppPurchaseService {
  static final InAppPurchaseService _instance = InAppPurchaseService._internal();
  factory InAppPurchaseService() => _instance;
  InAppPurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  
  // Product IDs for different ad packages
  static const String basicAdProductId = 'basic_ad_package';
  static const String premiumAdProductId = 'premium_ad_package';
  static const String featuredAdProductId = 'featured_ad_package';
  
  static const Set<String> productIds = {
    basicAdProductId,
    premiumAdProductId,
    featuredAdProductId,
  };

  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  // Callback for purchase completion
  Function(PurchaseDetails)? onPurchaseCompleted;
  Function(PurchaseDetails)? onPurchaseError;

  Future<void> initialize() async {
    try {
      _isAvailable = await _inAppPurchase.isAvailable();
      
      if (!_isAvailable) {
        debugPrint('In-app purchase not available');
        return;
      }

      // iOS-specific initialization can be added here if needed
      // Currently using basic initialization

      // Load products
      await _loadProducts();
      
      // Listen for purchases
      _subscription = _inAppPurchase.purchaseStream.listen(
        _handlePurchaseUpdate,
        onError: (error) {
          debugPrint('Purchase stream error: $error');
        },
      );

      // Restore previous purchases
      await _restorePurchases();
      
    } catch (e) {
      debugPrint('Failed to initialize in-app purchase: $e');
    }
  }

  Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse response = 
          await _inAppPurchase.queryProductDetails(productIds);
      
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('Products not found: ${response.notFoundIDs}');
      }
      
      _products = response.productDetails;
      debugPrint('Loaded ${_products.length} products');
      
    } catch (e) {
      debugPrint('Failed to load products: $e');
    }
  }

  Future<bool> purchaseProduct(String productId) async {
    try {
      if (!_isAvailable) {
        debugPrint('In-app purchase not available');
        return false;
      }

      // In debug mode, simulate successful purchase
      if (kDebugMode) {
        debugPrint('Debug mode: Simulating purchase for $productId');
        _simulateDebugPurchase(productId);
        return true;
      }

      final product = _products.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw Exception('Product not found'),
      );

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );

      await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      return true;
      
    } catch (e) {
      debugPrint('Purchase failed: $e');
      return false;
    }
  }

  void _simulateDebugPurchase(String productId) {
    // Simulate a successful purchase in debug mode
    final simulatedPurchase = PurchaseDetails(
      productID: productId,
      purchaseID: 'debug_${DateTime.now().millisecondsSinceEpoch}',
      transactionDate: DateTime.now().millisecondsSinceEpoch.toString(),
      status: PurchaseStatus.purchased,
      verificationData: PurchaseVerificationData(
        localVerificationData: 'debug_verification',
        serverVerificationData: 'debug_server_verification',
        source: 'debug',
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      _handlePurchaseUpdate([simulatedPurchase]);
    });
  }

  void _handlePurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      debugPrint('Purchase update: ${purchaseDetails.status}');
      
      if (purchaseDetails.status == PurchaseStatus.purchased) {
        // Verify purchase and process
        _processPurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        // Handle error
        onPurchaseError?.call(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show pending UI
        debugPrint('Purchase pending: ${purchaseDetails.productID}');
      }

      // Complete the purchase
      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  void _processPurchase(PurchaseDetails purchaseDetails) {
    try {
      // In debug mode or after verification, call completion callback
      onPurchaseCompleted?.call(purchaseDetails);
      debugPrint('Purchase processed successfully: ${purchaseDetails.productID}');
      
    } catch (e) {
      debugPrint('Failed to process purchase: $e');
      onPurchaseError?.call(purchaseDetails);
    }
  }

  Future<void> _restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      debugPrint('Failed to restore purchases: $e');
    }
  }

  entities.PurchaseType getAdTypeFromProductId(String productId) {
    switch (productId) {
      case basicAdProductId:
        return entities.PurchaseType.basicAd;
      case premiumAdProductId:
        return entities.PurchaseType.premiumAd;
      case featuredAdProductId:
        return entities.PurchaseType.featured;
      default:
        return entities.PurchaseType.basicAd;
    }
  }

  double getAmountFromProductId(String productId) {
    final product = _products.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw Exception('Product not found'),
    );
    
    // In debug mode, return mock prices
    if (kDebugMode) {
      switch (productId) {
        case basicAdProductId:
          return 10000.0; // 10,000 KRW
        case premiumAdProductId:
          return 30000.0; // 30,000 KRW
        case featuredAdProductId:
          return 50000.0; // 50,000 KRW
        default:
          return 10000.0;
      }
    }
    
    return double.tryParse(product.rawPrice.toString()) ?? 0.0;
  }

  void dispose() {
    _subscription.cancel();
  }
}

// Removed iOS delegate implementation for now
// Can be added back with proper imports if needed