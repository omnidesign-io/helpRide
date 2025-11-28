import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:helpride/l10n/generated/app_localizations.dart';
import 'package:helpride/core/constants/app_constants.dart';

class PhoneInputWidget extends StatefulWidget {
  final String? initialCountryCode; // e.g. '852'
  final String? initialPhoneNumber; // e.g. '12345678'
  final ValueChanged<String> onChanged; // Returns full E.164 number e.g. +85212345678
  final bool enabled;

  const PhoneInputWidget({
    super.key,
    this.initialCountryCode,
    this.initialPhoneNumber,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  State<PhoneInputWidget> createState() => _PhoneInputWidgetState();
}

class _PhoneInputWidgetState extends State<PhoneInputWidget> {
  late Country _selectedCountry;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final initialCode = widget.initialCountryCode ?? '852';
    
    // Try to find by phone code first if it looks like a number
    if (RegExp(r'^\d+$').hasMatch(initialCode)) {
      _selectedCountry = CountryService().findByPhoneCode(initialCode) ?? Country.parse('HK');
    } else {
      // Otherwise try to parse as ISO code or name
      try {
        _selectedCountry = Country.parse(initialCode);
      } catch (e) {
        _selectedCountry = Country.parse('HK'); // Fallback to HK
      }
    }
    
    _phoneController = TextEditingController(text: widget.initialPhoneNumber);
    _phoneController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _phoneController.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    _notifyChanged();
  }

  void _notifyChanged() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      widget.onChanged('');
      return;
    }
    widget.onChanged('+${_selectedCountry.phoneCode}$phone');
  }

  void _showCountryPicker() {
    if (!widget.enabled) return;
    
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        setState(() {
          _selectedCountry = country;
        });
        _notifyChanged();
      },
      countryListTheme: CountryListThemeData(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        inputDecoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.searchCountry,
          hintText: AppLocalizations.of(context)!.searchCountry,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: const Color(0xFF8C98A8).withValues(alpha: 0.2),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputTheme = theme.inputDecorationTheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: inputTheme.fillColor,
        borderRadius: BorderRadius.circular(kInputBorderRadius),
        // No border stroke to match standard fields which have BorderSide.none
      ),
      child: Row(
        children: [
          InkWell(
            onTap: _showCountryPicker,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Row(
                children: [
                  Text(
                    _selectedCountry.flagEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '+${_selectedCountry.phoneCode}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (widget.enabled) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, size: 20),
                  ],
                ],
              ),
            ),
          ),
          Container(
            width: 1,
            height: 24,
            color: Colors.grey.shade400, // Slightly darker to be visible on grey background
          ),
          Expanded(
            child: TextField(
              controller: _phoneController,
              enabled: widget.enabled,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: const EdgeInsets.fromLTRB(12, 16, 16, 16),
                hintText: l10n.phoneNumberHint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
