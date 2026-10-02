import 'package:flutter/material.dart';
import 'package:fs_sa/data/models/legacy/intersport_partner.dart';
import 'package:fs_sa/data/models/objectbox/log.dart';
import 'package:fs_sa/data/services/intersport_service.dart';
import 'package:fs_sa/data/services/local/log_local.dart';
import 'package:fs_sa/data/services/user_service.dart';
import 'package:fs_sa/presentation/core/themes.dart';
import 'package:fs_sa/presentation/features/home/add_club/add_club_controller.dart';
import 'package:fs_sa/presentation/features/home/home_controller.dart';
import 'package:fs_sa/presentation/utils/local_authentication.dart';
import 'package:fs_sa/presentation/utils/responsive.dart';
import 'package:fs_sa/presentation/widgets/notification_banner.dart';

class AddClubView extends StatefulWidget {
  const AddClubView({super.key});

  @override
  State<AddClubView> createState() => _AddClubViewState();
}

class _AddClubViewState extends State<AddClubView> with Responsive, LocalAuth {
  final _formKey = GlobalKey<FormState>();
  final _clubNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _demoController = TextEditingController();
  final _maxMembersController = TextEditingController(text: '10');
  final _priceController = TextEditingController(text: '0');
  final _intersportClubIdController = TextEditingController();

  bool _showEmailField = false;
  bool _isLoading = false;
  String role = '1';
  final roleName = {'1': 'director', '2': 'manager'};
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  // * Flow 2 — optionally link the freshly-created club to an Intersport
  // * boutique. The PDG got the intersport_club_id + partner from the
  // * Intersport admin's email.
  bool _linkIntersport = false;
  bool _loadingPartners = false;
  List<IntersportPartner> _partners = [];
  IntersportPartner? _selectedPartner;
  final _uuidRegex = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  Future<void> _loadPartners() async {
    setState(() => _loadingPartners = true);
    final res = await intersportService.listPartners();
    if (!mounted) return;
    setState(() {
      _partners = res.where((p) => p.isActive).toList();
      _loadingPartners = false;
    });
  }

  @override
  void initState() {
    addClubCtrler.init(setState, context);
    super.initState();
  }

  void _submitForm() async {
    // * Run field-level validators first — they handle empty / non-integer
    // * input. Without this guard, `int.parse('')` below throws FormatException
    // * the moment the user taps submit on an empty form.
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final clubNumber = int.parse(_clubNumberController.text);
    final email = _showEmailField ? _emailController.text : null;
    final maxMembers = int.parse(_maxMembersController.text);
    final pricePerMember = _priceController.text;
    final demo = _demoController.text;

    // * Flow 2 — validate the Intersport fields up front so we never create
    // * a club and then fail the link on a typo.
    if (_linkIntersport) {
      if (_selectedPartner == null) {
        context.showErrorNotification('Select an Intersport partner');
        return;
      }
      if (!_uuidRegex.hasMatch(_intersportClubIdController.text.trim())) {
        context.showErrorNotification(
          'Invalid Intersport club ID — must be a UUID',
        );
        return;
      }
    }

    if (await authenticate() == false) {
      context.showErrorNotification('Authentication Failed, Show Logs');

      setState(() {
        _isLoading = false;
      });

      return;
    }

    setState(() {
      _isLoading = true;
    });

    final club = await addClubCtrler.addNewClub(
      demo,
      clubNumber,
      maxMembers,
      pricePerMember == '0' ? 0.0 : double.parse(pricePerMember),
    );

    if (club != null) {
      logLocal.addLog(
        LogEntity(
          source:
              'addNewClub($demo, $clubNumber, $maxMembers, $pricePerMember)',
          message: 'club id: ${club['clubId']}, club name: ${club['name']}',
          level: 'info',
        ),
      );

      context.showSuccessNotification(
        'New club added successfully',
        title: club['name'],
      );

      if (email != null) {
        await userService.addMember({
          'clubId': club['clubId'],
          'email': email,
          'role': int.parse(role),
          'license_number': 0,
        });

        context.showSuccessNotification(
          'Member added successfully to ${club['name']}',
        );

        homeCtrler.pushStream(0);
      }

      if (_linkIntersport) {
        final clubId = (club['clubId'] as num).toInt();
        final res = await intersportService.createClubFromEmail(
          clubId: clubId,
          intersportClubId:
              _intersportClubIdController.text.trim().toLowerCase(),
          intersportPartnerId: _selectedPartner!.id,
        );

        if (res.ok) {
          context.showSuccessNotification(
            'Linked to Intersport — ${_selectedPartner!.name}',
          );
        } else {
          // * Club exists; only the link failed — recoverable, PDG can
          // * retry the link without re-creating the club.
          context.showErrorNotification(
            'Club created, but Intersport link failed: ${res.error ?? 'unknown'}',
          );
        }
      }
    } else {
      context.showErrorNotification('Add club failed');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _intersportClubIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widthScreen,
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: secondary),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      // Bottom right
                      color: Colors.green,
                      offset: Offset(2, 2),
                      blurRadius: 10,
                    ),
                    BoxShadow(
                      // Top left
                      color: Colors.green,
                      offset: Offset(-2, -2),
                      blurRadius: 10,
                    ),
                  ],
                ),

                child: Text(
                  '💰 More money baby 💰',
                  style: TextStyle(
                    fontSize: 22.0,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        // Bottom right
                        color: Colors.blue,
                        offset: Offset(2, 2),
                        blurRadius: 10,
                      ),
                      Shadow(
                        // Top left
                        color: Colors.purple,
                        offset: Offset(-2, -2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),

              // * Demo email field
              TextFormField(
                controller: _demoController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email (demo...@footspot.com)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                validator: (value) {
                  if (_showEmailField && (value == null || value.isEmpty)) {
                    return 'Please enter an email address';
                  }
                  if (_showEmailField && value != null && value.isNotEmpty) {
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                  }
                  return null;
                },
              ),
              SizedBox(height: 10.0),
              TextFormField(
                controller: _clubNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Club Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.pin_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a club number';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid integer';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10.0),

              // Max Members Field
              TextFormField(
                controller: _maxMembersController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Max Members',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.groups,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter maximum members';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid integer';
                  }
                  int? maxMembers = int.tryParse(value);
                  if (maxMembers != null && maxMembers <= 0) {
                    return 'Max members must be greater than 0';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10.0),

              // Price per Member per Year Field
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Price per member per year',
                  border: OutlineInputBorder(),
                  suffixText: '€',
                  suffixIcon: Icon(
                    Icons.euro_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price per member per year';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  double? price = double.tryParse(value);
                  if (price != null && price < 0) {
                    return 'Price cannot be negative';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              // Email Checkbox
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _showEmailField,
                    onChanged: (bool? value) {
                      setState(() {
                        _showEmailField = value ?? false;
                        if (!_showEmailField) {
                          _emailController.clear();
                        }
                      });
                    },
                  ),
                  Text('Add Member'),
                ],
              ),

              // Email Field (conditionally shown)
              if (_showEmailField) ...[
                SizedBox(height: 8.0),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email member',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  validator: (value) {
                    if (_showEmailField && (value == null || value.isEmpty)) {
                      return 'Please enter an email address';
                    }
                    if (_showEmailField && value != null && value.isNotEmpty) {
                      if (!emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),
                DropdownButtonFormField<String>(
                  initialValue: role,
                  items: const [
                    DropdownMenuItem(value: '1', child: Text('Director')),
                    DropdownMenuItem(value: '2', child: Text('Manager')),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      role = newValue ?? '';
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
              // * Flow 2 — link the new club to an Intersport boutique.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _linkIntersport,
                    onChanged: (value) {
                      setState(() => _linkIntersport = value ?? false);
                      if (_linkIntersport && _partners.isEmpty) {
                        _loadPartners();
                      }
                    },
                  ),
                  Text('Link to Intersport'),
                ],
              ),
              if (_linkIntersport) ...[
                if (_loadingPartners)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_partners.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No Intersport partner registered. Add one in the '
                      'Partnership tab first.',
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontSize: 12,
                      ),
                    ),
                  )
                else ...[
                  DropdownButtonFormField<IntersportPartner>(
                    initialValue: _selectedPartner,
                    isExpanded: true,
                    items:
                        _partners
                            .map(
                              (p) => DropdownMenuItem(
                                value: p,
                                child: Text('${p.name} — ${p.region}'),
                              ),
                            )
                            .toList(),
                    onChanged:
                        (p) => setState(() => _selectedPartner = p),
                    decoration: InputDecoration(
                      labelText: 'Intersport partner',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(
                        Icons.store_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    controller: _intersportClubIdController,
                    decoration: InputDecoration(
                      labelText: 'Intersport club ID (from email)',
                      hintText: 'a1b2c3d4-1234-1234-1234-1234567890ab',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(
                        Icons.tag,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ],
              SizedBox(height: 20.0),
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('loading...'),
                            ],
                          )
                          : Text(
                            'الحمد لله',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
