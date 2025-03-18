import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../constant/constants.dart';
import 'package:intl/intl.dart';

class AzoneLoyaltyCard extends StatelessWidget {
  final double availablePoints;
  final double nextTierPoints;
  final String membershipNumber;
  final String logoAssetPath; // Path to the Azone logo image asset
  final AzoneTier tier;
  final String nextTierName;
  final double totalPoints;

  const AzoneLoyaltyCard({
    super.key,
    required this.availablePoints,
    required this.membershipNumber,
    required this.nextTierPoints,
    required this.logoAssetPath,
    required this.tier,
    required this.nextTierName,
    required this.totalPoints,
  });

  Color _getProgressColor(AzoneTier tier) {
    switch (tier) {
      case AzoneTier.bronze:
        return const Color(0xFF7F8C8D);
      case AzoneTier.silver:
        return const Color(0xFFD4AF37);
      case AzoneTier.gold:
        return const Color(0xFFE5E4E2);
      case AzoneTier.platinum:
        return Colors.green;
    }
  }

  Color _getCircularBackgroundColor(AzoneTier tier) {
    switch (tier) {
      case AzoneTier.bronze:
        return const Color(0xFF7A4B18);
      case AzoneTier.silver:
        return const Color(0xFF7F8C8D);
      case AzoneTier.gold:
        return const Color(0xFFD4AF37);
      case AzoneTier.platinum:
        return Colors.green;
    }
  }

  LinearGradient _getGradientForTier(AzoneTier tier) {
    switch (tier) {
      case AzoneTier.bronze:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7A4B18),
            Color(0xFFB67D42),
          ],
        );
      case AzoneTier.silver:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7F8C8D),
            Color(0xFFBDC3C7),
          ],
        );
      case AzoneTier.gold:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFD4AF37),
            Color(0xFFFFD700),
          ],
        );
      case AzoneTier.platinum:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE5E4E2),
            Color(0xFFC0C0C0),
          ],
        );
    }
  }

  Color _getTierTextColor(AzoneTier tier) {
    switch (tier) {
      case AzoneTier.bronze:
        return Colors.white70;
      case AzoneTier.silver:
        return Colors.white70;
      case AzoneTier.gold:
        return Colors.black;
      case AzoneTier.platinum:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tierGradient = _getGradientForTier(tier);
    final circularBackgroundColor = _getCircularBackgroundColor(tier);
    final progressColor = _getProgressColor(tier);
    final tierTextColor = _getTierTextColor(tier);

    final double progressPercentage = nextTierPoints == 0 ? 100 : (availablePoints / nextTierPoints) * 100;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          gradient: tierGradient,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              // Decorative overlay (optional)
              Positioned(
                right: -60,
                top: -60,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              Positioned(
                left: -40,
                bottom: -40,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),

              // Card Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Azone Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset(
                        logoAssetPath,
                        height: 20,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),

                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Points Balance: ${NumberFormat.simpleCurrency(name: "", decimalDigits: 2).format(availablePoints)}", style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.bold, color: tierTextColor ),),
                          Text("Total Points: ${NumberFormat.simpleCurrency(name: "", decimalDigits: 2).format(totalPoints)}", style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.bold, color: tierTextColor ),),
                        ],
                      ),
                      CircularPercentIndicator(
                        radius: 35.0,
                        animation: true,
                        animationDuration: 1200,
                        lineWidth: 10.0,
                        percent: progressPercentage / 100,
                        center: Text(
                          "${progressPercentage.toStringAsFixed(0)}% to $nextTierName",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 7.0, color: tierTextColor),
                        ),
                        circularStrokeCap: CircularStrokeCap.butt,
                        backgroundColor: circularBackgroundColor, 
                        progressColor: progressColor,
                      ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  // Membership Number
                  Text(
                    "Membership No.",
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: tierTextColor,
                    ),
                  ),
                  // Expiry
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        membershipNumber,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: tierTextColor,
                        ),
                      ),
                      // Optional chip or security icon
                      Container(
                        width: 40,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.lock,
                          color: tierTextColor,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

