import 'package:flutter/material.dart';
import 'package:fs_sa/data/models/legacy/intersport_partner.dart';
import 'package:intl/intl.dart';

class PartnerCard extends StatelessWidget {
  const PartnerCard({super.key, required this.partner});

  final IntersportPartner partner;

  @override
  Widget build(BuildContext context) {
    final color = partner.isActive ? Colors.green : Colors.orange;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    partner.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color),
                  ),
                  child: Text(
                    partner.status,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              partner.region,
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
            const SizedBox(height: 10),
            _kv('Base URL', partner.baseUrl),
            _kv('Shop prefix', partner.shopUrlPrefix),
            _kv(
              'Linked clubs',
              partner.linkedClubsCount.toString(),
            ),
            _kv(
              'Registered',
              DateFormat('d MMM yyyy').format(partner.registeredAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              k,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
