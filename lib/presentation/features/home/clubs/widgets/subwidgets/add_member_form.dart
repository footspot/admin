import 'package:flutter/material.dart';
import 'package:fs_sa/data/models/objectbox/club_sub_entity.dart';
import 'package:fs_sa/presentation/features/home/clubs/clubs_controller.dart';
import 'package:fs_sa/presentation/utils/local_authentication.dart';
import 'package:fs_sa/presentation/widgets/notification_banner.dart';
import 'package:fs_sa/presentation/widgets/square_close_button.dart';

class AddDirectorForm extends StatefulWidget {
  const AddDirectorForm({super.key, required this.club, required this.close});

  final ClubSubscriptionEntity club;
  final VoidCallback close;

  @override
  State<AddDirectorForm> createState() => _AddDirectorFormState();
}

class _AddDirectorFormState extends State<AddDirectorForm> with LocalAuth {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _licenseController = TextEditingController();
  bool _isLoading = false;
  String role = '1';

  final roleName = {'1': 'director', '2': 'manager'};

  @override
  void dispose() {
    _emailController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      if (await authenticate() == false) {
        context.showErrorNotification('Authentication Failed, Show Logs');

        setState(() {
          _isLoading = false;
        });

        return;
      }

      final res = await clubsCtrler.addDirector(
        // * Pass the club id, NOT widget.club.id (that's the right_subscription
        // * id). The aam function looks members up by club_id.
        widget.club.club.target!.id,
        _emailController.text.trim(),
        int.parse(role),
        _licenseController.text.trim(),
      );

      setState(() {
        _isLoading = false;
      });

      // Show success message
      res == true
          ? context.showSuccessNotification(
            title: 'Add member',
            'Email submitted successfully: ${_emailController.text}',
          )
          : context.showErrorNotification(
            title: 'Error',
            'Add member failed !',
          );

      _emailController.clear();

      widget.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Form(
        key: _formKey,
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add ${roleName[role]!.toUpperCase()} to\n${widget.club.club.target!.name}',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    labelText: 'Email *',
                    hintText: 'example@email.com',
                    prefixIcon: Icon(
                      Icons.email,
                      color: Theme.of(context).colorScheme.primary,
                    ),
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
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.red),
                    ),
                  ),
                  validator: _validateEmail,
                ),
                SizedBox(height: 8.0),
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
                SizedBox(height: 16),
                TextFormField(
                  controller: _licenseController,
                  keyboardType: TextInputType.number,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    labelText: 'License',
                    suffixText: 'Optional',
                    prefixIcon: Icon(
                      Icons.badge_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
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
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                ElevatedButton(
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
                            'Add',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
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
