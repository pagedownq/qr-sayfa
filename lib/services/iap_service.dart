import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../utils/app_state.dart';

class IAPService extends ChangeNotifier {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  bool isAvailable = false;
  bool isPremium = false;
  List<ProductDetails> products = [];

  // TODO: Google Play Console'dan oluşturduğunuz abonelik ID'lerini buraya ekleyin
  final List<String> _productIds = ['premium_monthly', 'premium_yearly'];

  Future<void> initialize() async {
    // 1. Satın alma akışını dinlemeye başla
    final purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      debugPrint("IAP Initialize Error: $error");
    });
    
    // 2. Mağaza bilgilerini (fiyatlar vs) çek
    await _initStoreInfo();

    // 3. Canlı kontrol: Mevcut satın almaları/abonelikleri Google Play'den çek
    // Eğer internet varsa ve mağaza müsaitse kontrol et
    if (isAvailable) {
      try {
        debugPrint("IAP: Checking live subscription status...");
        // restorePurchases her açılışta tetiklenmek yerine sessizce bekleyebilir 
        // veya sadece premium olmayanlar için tetiklenebilir.
        // Ama abonelik bitişini anlamak için stream zaten güncellenecektir.
        await _inAppPurchase.restorePurchases();
      } catch (e) {
        debugPrint("IAP Restore Error on Init: $e");
      }
    }
  }

  Future<void> _initStoreInfo() async {
    try {
      isAvailable = await _inAppPurchase.isAvailable();
      if (!isAvailable) {
        notifyListeners();
        return;
      }

      ProductDetailsResponse productDetailResponse =
          await _inAppPurchase.queryProductDetails(_productIds.toSet());
      
      if (productDetailResponse.error != null) {
        debugPrint("Query Product Error: ${productDetailResponse.error!.message}");
        return;
      }

      products = productDetailResponse.productDetails;
    } catch (e) {
      debugPrint("IAP Store Info Error: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> buyProduct(ProductDetails productDetails) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    await _inAppPurchase.restorePurchases();
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    bool updated = false;
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Satın alma işlemi beklemede
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint("Purchase Error: ${purchaseDetails.error}");
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                   purchaseDetails.status == PurchaseStatus.restored) {
          
          if (_productIds.contains(purchaseDetails.productID)) {
            if (!isPremiumNotifier.value) {
              isPremiumNotifier.value = true;
              updated = true;
            }
            isPremium = true;
            debugPrint("IAP: Premium confirmed for ${purchaseDetails.productID}");
          }
        }
        
        if (purchaseDetails.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
    if (updated) notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
