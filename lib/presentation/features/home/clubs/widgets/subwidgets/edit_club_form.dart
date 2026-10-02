import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fs_sa/data/models/objectbox/club_sub_entity.dart';
import 'package:fs_sa/presentation/core/themes.dart';
import 'package:fs_sa/presentation/features/home/clubs/clubs_controller.dart';
import 'package:fs_sa/presentation/utils/local_authentication.dart';
import 'package:fs_sa/presentation/widgets/notification_banner.dart';
import 'package:fs_sa/presentation/widgets/square_close_button.dart';

class EditClubForm extends StatefulWidget {
  const EditClubForm({super.key, required this.rs, required this.close});

  final ClubSubscriptionEntity rs;
  final VoidCallback close;

  @override
  State<EditClubForm> createState() => _EditClubFormState();
}

class _EditClubFormState extends State<EditClubForm> with LocalAuth {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _maxMembersController = TextEditingController();

  double? pricePerMemberPerYear;
  int? maxMembers;
  bool isLoading = false;

  @override
  void dispose() {
    _priceController.dispose();
    _maxMembersController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      var price =
          _priceController.text.isEmpty
              ? widget.rs.priceMember.toString()
              : _priceController.text;

      var maxMembers =
          _maxMembersController.text.isEmpty
              ? widget.rs.membersLimit.toString()
              : _maxMembersController.text;

      setState(() {
        isLoading = true;
      });

      if (await authenticate() == false) {
        context.showErrorNotification('Authentication Failed, Show Logs');

        setState(() {
          isLoading = false;
        });

        return;
      }

      final res = await clubsCtrler.editClub(widget.rs.id, price, maxMembers);

      setState(() {
        isLoading = false;
      });

      // Show success message
      res == true
          ? context.showSuccessNotification(
            'Infos edited successfully',
            title: 'Form Submitted',
          )
          : context.showErrorNotification(title: 'Error', 'Edit failed !');

      _priceController.clear();
      _maxMembersController.clear();

      widget.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Price & Members',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Price per member per year field
                TextFormField(
                  textAlign: TextAlign.right,
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Price per member per year',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(
                      Icons.euro_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final price = double.tryParse(value);
                      if (price == null) {
                        return 'Please enter a valid number';
                      }
                      if (price <= 0) {
                        return 'Price must be greater than 0';
                      }
                    }
                    return null;
                  },
                  onSaved: (value) {
                    pricePerMemberPerYear = double.tryParse(value!);
                  },
                ),
                const SizedBox(height: 16),

                // Max members field
                TextFormField(
                  controller: _maxMembersController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Max members',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.groups,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final members = int.tryParse(value);
                      if (members == null) {
                        return 'Please enter a valid number';
                      }
                      if (members <= 0) {
                        return 'Max members must be greater than 0';
                      }
                    }

                    return null;
                  },
                  onSaved: (value) {
                    maxMembers = int.tryParse(value!);
                  },
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryLight,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        isLoading
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
                              'Edit',
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
            Positioned(
              right: 0.0,
              child: SquareCloseButton(onPressed: widget.close),
            ),
          ],
        ),
      ),
    );
  }
}
