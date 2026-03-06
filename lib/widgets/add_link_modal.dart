import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:image_picker/image_picker.dart';

import '../models/social_link.dart';
import '../utils/link_manager.dart';
import '../services/analytics_service.dart';
import '../utils/app_state.dart';
import '../screens/premium_screen.dart';
import '../utils/logo_generator.dart';
import '../services/metadata_service.dart';
import '../constants/platforms.dart';
import '../services/haptic_service.dart';
import 'dart:async';
import 'add_link/add_link_components.dart';
import 'add_link/free_user_banner.dart';
import '../l10n/app_localizations.dart';

void showAddLinkModal(BuildContext context, Map<String, dynamic> platform) {
  final TextEditingController urlController = TextEditingController();
  final TextEditingController nameController = TextEditingController(
    text: platform['name'],
  );
  final TextEditingController wifiSsidController = TextEditingController();
  final TextEditingController wifiPasswordController = TextEditingController();

  final bool isOther = platform['name'] == 'Diğer';
  final bool isWifi = platform['name'] == 'WiFi';
  final bool isPhone = platform['name'] == 'Telefon';

  String currentCategory = 'personal';
  Color selectedQrColor = Colors.black;
  Color selectedQrBgColor = CupertinoColors.white;
  String selectedQrShape = 'square';
  String selectedQrEyeShape = 'square';
  String? selectedLogoPath;
  bool useLogo = false;
  bool _hasInitLogo = false;
  bool _isFetchingMetadata = false;
  Timer? _debounceTimer;

  void _onUrlChanged(String val, StateSetter setDialogState) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () async {
      if (val.isEmpty) return;

      // 1. Detect Platform
      final detectedId = MetadataService.detectPlatform(val);
      if (detectedId != null && detectedId != platform['id']) {
        final detectedPlatform = AppPlatforms.availablePlatforms.firstWhere(
          (p) => p.id == detectedId,
          orElse: () => AppPlatforms.availablePlatforms.first,
        );
        
        // Ask or notify user? For now, we update if it's "Other"
        if (platform['id'] == 'other') {
           // We could potentially switch the platform data here if we had more state control
        }
      }

      // 2. Fetch Metadata
      if (val.startsWith('http')) {
        setDialogState(() => _isFetchingMetadata = true);
        final metadata = await MetadataService.fetchMetadata(val);
        setDialogState(() {
          _isFetchingMetadata = false;
          if (metadata?.title != null && isOther) {
            nameController.text = metadata!.title!;
          }
        });
      }
    });
  }

  void showToast(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(tr('success')),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text(tr('ok')),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  showCupertinoModalPopup(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          if (!_hasInitLogo && !isWifi && !isPhone && !isOther) {
            _hasInitLogo = true;
            LogoGenerator.saveIconToImage(platform['icon'], platform['color']).then((path) {
              if (context.mounted) {
                setDialogState(() {
                  selectedLogoPath = path;
                  useLogo = true;
                });
              }
            });
          }

          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0x1AFFFFFF))),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => Navigator.pop(context),
                            child: Text(tr('cancel'), style: const TextStyle(color: CupertinoColors.systemRed)),
                          ),
                          Text(
                            isWifi ? tr('add_wifi') : '${platform['name']} ${tr('add_text')}',
                            style: const TextStyle(
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              String finalUrl = '';
                              String finalName = '';

                              if (isPhone) {
                                final phone = urlController.text.trim();
                                if (phone.isNotEmpty) {
                                  finalUrl = phone.startsWith('tel:') ? phone : 'tel:$phone';
                                  finalName = phone;
                                }
                              } else if (isWifi) {
                                final ssid = wifiSsidController.text.trim();
                                final pass = wifiPasswordController.text.trim();
                                if (ssid.isNotEmpty) {
                                  finalUrl = 'WIFI:S:$ssid;T:WPA;P:$pass;;';
                                  finalName = ssid;
                                }
                              } else {
                                finalUrl = urlController.text.trim();
                                finalName = isOther
                                    ? nameController.text.trim()
                                    : platform['name'];
                              }

                              if (finalUrl.isNotEmpty && finalName.isNotEmpty) {
                                final (bool canAdd, String errorMsg) = LinkManager.canAddLink(
                                  finalUrl, 
                                  finalName, 
                                  platform['id']
                                );
                                
                                if (!canAdd) {
                                  showCupertinoDialog(
                                    context: context,
                                    builder: (context) => CupertinoAlertDialog(
                                      title: Text(tr('cannot_add')),
                                      content: Text(errorMsg),
                                      actions: [
                                        CupertinoDialogAction(
                                          isDefaultAction: true,
                                          child: Text(tr('ok')),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                  );
                                  return;
                                }

                                final newLink = SocialLink(
                                  platform: finalName,
                                  platformId: platform['id'],
                                  icon: platform['icon'],
                                  color: platform['color'],
                                  url: finalUrl,
                                  category: currentCategory,
                                  qrColor: selectedQrColor,
                                  qrBgColor: selectedQrBgColor,
                                  qrShape: selectedQrShape,
                                  qrEyeShape: selectedQrEyeShape,
                                  qrLogoPath: useLogo ? selectedLogoPath : null,
                                );

                                LinkManager.addLink(newLink, platform['id']).then((success) {
                                  if (success && context.mounted) {
                                    Navigator.pop(context);
                                    showToast('$finalName ${tr('added_successfully')}');
                                  }
                                });
                              }
                            },
                            child: Text(tr('add'), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00D2FF))),
                          ),
                        ],
                      ),
                    ),
                    
                    // Body
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        children: [
                          Center(
                            child: Column(
                              children: [
                                Icon(platform['icon'], color: platform['color'], size: 56),
                                const SizedBox(height: 12),
                                RepaintBoundary(
                                  child: CupertinoSlidingSegmentedControl<String>(
                                    groupValue: currentCategory,
                                    backgroundColor: const Color(0xFF1E293B),
                                    thumbColor: const Color(0xFF00D2FF),
                                    children: {
                                      'personal': SegmentedText(text: tr('personal'), isSelected: currentCategory == 'personal'),
                                      'business': SegmentedText(text: tr('business'), isSelected: currentCategory == 'business'),
                                    },
                                    onValueChanged: (val) {
                                      if (val != null) {
                                        HapticService.selectionClick();
                                        setDialogState(() => currentCategory = val);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          if (isPhone) ...[
                            InputLabel(label: tr('phone_number')),
                            CupertinoInput(controller: urlController, placeholder: tr('example_phone'), type: TextInputType.phone),
                          ] else if (isWifi) ...[
                            InputLabel(label: tr('wifi_details')),
                            CupertinoInput(controller: wifiSsidController, placeholder: tr('network_name_ssid')),
                            const SizedBox(height: 12),
                            CupertinoInput(controller: wifiPasswordController, placeholder: tr('password'), type: TextInputType.text, obscure: true),
                          ] else ...[
                            if (isOther) ...[
                              InputLabel(label: tr('title')),
                              CupertinoInput(controller: nameController, placeholder: tr('example_portfolio')),
                              const SizedBox(height: 16),
                            ],
                            InputLabel(label: tr('connection_link')),
                            CupertinoTextField(
                              controller: urlController,
                              placeholder: platform['inputHint'] ?? tr('connection_link'),
                              keyboardType: TextInputType.url,
                              placeholderStyle: const TextStyle(color: CupertinoColors.systemGrey, fontSize: 14),
                              style: const TextStyle(color: CupertinoColors.white, fontSize: 15),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0x33FFFFFF)),
                              ),
                              onChanged: (v) => _onUrlChanged(v, setDialogState),
                              suffix: RepaintBoundary(
                                child: _isFetchingMetadata 
                                  ? const Padding(
                                      padding: EdgeInsets.only(right: 12),
                                      child: CupertinoActivityIndicator(radius: 8),
                                    )
                                  : const SizedBox.shrink(),
                              ),
                            ),
                          ],

                          const SizedBox(height: 40),

                          ValueListenableBuilder<bool>(
                            valueListenable: isPremiumNotifier,
                            builder: (context, isPremium, child) {
                              if (!isPremium) {
                                return const FreeUserBanner();
                              }
                              return Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E293B).withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFD700).withOpacity(0.15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(CupertinoIcons.star_fill, color: Color(0xFFFFD700), size: 16),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          tr('premium_qr_design'),
                                          style: const TextStyle(
                                            color: Color(0xFFFFD700),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    
                                    InputLabel(label: tr('qr_color')),
                                    const SizedBox(height: 12),
                                    ColorPalette(selected: selectedQrColor, onSelect: (color) {
                                      setDialogState(() => selectedQrColor = color);
                                    }),
                                    
                                    const SizedBox(height: 32),
                                    InputLabel(label: tr('body_shapes_dots')),
                                    const SizedBox(height: 12),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          LinkDesignCard(
                                            label: tr('square'),
                                            isSelected: selectedQrShape == 'square',
                                            onTap: () => setDialogState(() => selectedQrShape = 'square'),
                                            child: const Icon(CupertinoIcons.square_fill, color: CupertinoColors.white, size: 24),
                                          ),
                                          LinkDesignCard(
                                            label: tr('dot'),
                                            isSelected: selectedQrShape == 'dots',
                                            onTap: () => setDialogState(() => selectedQrShape = 'dots'),
                                            child: const Icon(CupertinoIcons.circle_fill, color: CupertinoColors.white, size: 24),
                                          ),
                                          LinkDesignCard(
                                            label: tr('oval'),
                                            isSelected: selectedQrShape == 'rounded',
                                            onTap: () => setDialogState(() => selectedQrShape = 'rounded'),
                                            child: Container(
                                              width: 20, height: 20,
                                              decoration: BoxDecoration(
                                                color: CupertinoColors.white,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 32),
                                    InputLabel(label: tr('outer_eye_patterns')),
                                    const SizedBox(height: 12),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          LinkDesignCard(
                                            label: tr('square'),
                                            isSelected: selectedQrEyeShape == 'square',
                                            onTap: () => setDialogState(() => selectedQrEyeShape = 'square'),
                                            child: ShapeIcon(icon: CupertinoIcons.square, isSelected: selectedQrEyeShape == 'square'),
                                          ),
                                          LinkDesignCard(
                                            label: tr('circle'),
                                            isSelected: selectedQrEyeShape == 'circle',
                                            onTap: () => setDialogState(() => selectedQrEyeShape = 'circle'),
                                            child: ShapeIcon(icon: CupertinoIcons.circle, isSelected: selectedQrEyeShape == 'circle'),
                                          ),
                                          LinkDesignCard(
                                            label: tr('modern'),
                                            isSelected: selectedQrEyeShape == 'rounded',
                                            onTap: () => setDialogState(() => selectedQrEyeShape = 'rounded'),
                                            child: Container(
                                              width: 24, height: 24,
                                              decoration: BoxDecoration(
                                                border: Border.all(color: CupertinoColors.white, width: 2.5),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 32),
                                    InputLabel(label: tr('logo_settings')),
                              
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: CupertinoButton(
                                            padding: EdgeInsets.zero,
                                            onPressed: () async {
                                              final picker = ImagePicker();
                                              final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                                              if (pickedFile != null) {
                                                setDialogState(() {
                                                  selectedLogoPath = pickedFile.path;
                                                  useLogo = true;
                                                });
                                              }
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF0F172A),
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(color: useLogo ? const Color(0xFFFFD700) : const Color(0x33FFFFFF)),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    useLogo ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.photo_on_rectangle,
                                                    color: useLogo ? const Color(0xFFFFD700) : CupertinoColors.white,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    useLogo ? tr('change_logo') : tr('select_custom_logo'),
                                                    style: const TextStyle(fontSize: 14, color: CupertinoColors.white, fontWeight: FontWeight.w600),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (useLogo) ...[
                                          const SizedBox(width: 12),
                                          CupertinoButton(
                                            padding: EdgeInsets.zero,
                                            onPressed: () => setDialogState(() {
                                              useLogo = false;
                                              selectedLogoPath = null;
                                            }),
                                            child: Container(
                                              padding: const EdgeInsets.all(14),
                                              decoration: BoxDecoration(
                                                color: CupertinoColors.systemRed.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: const Icon(CupertinoIcons.trash, color: CupertinoColors.systemRed, size: 20),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

