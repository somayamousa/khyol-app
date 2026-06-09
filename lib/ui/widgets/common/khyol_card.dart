import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/center_model.dart';
import '../../../data/models/event_model.dart';

class KhyolCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double? width;

  const KhyolCard({super.key, required this.child, this.onTap, this.width});

  factory KhyolCard.product(ProductModel p, {VoidCallback? onTap}) {
    return KhyolCard(
      onTap: onTap,
      width: 160,
      child: _ProductCardContent(p),
    );
  }

  factory KhyolCard.center(CenterModel c, {VoidCallback? onTap}) {
    return KhyolCard(
      onTap: onTap,
      width: 200,
      child: _CenterCardContent(c),
    );
  }

  factory KhyolCard.event(EventModel e, {VoidCallback? onTap}) {
    return KhyolCard(
      onTap: onTap,
      width: 220,
      child: _EventCardContent(e),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}

class _ProductCardContent extends StatelessWidget {
  final ProductModel p;
  const _ProductCardContent(this.p);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            children: [
              if (p.image != null)
                CachedNetworkImage(imageUrl: p.image!, width: double.infinity, fit: BoxFit.cover)
              else
                Container(color: AppColors.bg3, child: const Center(child: Icon(Icons.image_outlined, color: AppColors.textMuted))),
              if (p.oldPrice != null)
                Positioned(
                  top: 8, right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(6)),
                    child: const Text('خصم', style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.white)),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.name, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text('${p.price.toInt()} ₪', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.gold)),
                  if (p.oldPrice != null) ...[
                    const SizedBox(width: 6),
                    Text('${p.oldPrice!.toInt()} ₪', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textMuted, decoration: TextDecoration.lineThrough)),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CenterCardContent extends StatelessWidget {
  final CenterModel c;
  const _CenterCardContent(this.c);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (c.image != null)
          CachedNetworkImage(imageUrl: c.image!, height: 120, width: double.infinity, fit: BoxFit.cover)
        else
          Container(height: 120, color: AppColors.bg3, child: const Center(child: Icon(Icons.home_outlined, color: AppColors.textMuted))),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(c.name, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
              if (c.city != null)
                Text('📍 ${c.city}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textMuted)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 12)),
                  Text(' ${c.rating}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w600)),
                  Text(' (${c.reviewsCount})', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EventCardContent extends StatelessWidget {
  final EventModel e;
  const _EventCardContent(this.e);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (e.image != null)
          CachedNetworkImage(imageUrl: e.image!, height: 100, width: double.infinity, fit: BoxFit.cover)
        else
          Container(height: 100, color: AppColors.bg3),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(e.typeLabel, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.gold)),
              Text(e.title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(e.isFree ? 'مجاناً' : '${e.price.toInt()} ₪',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700, color: e.isFree ? AppColors.success : AppColors.gold)),
            ],
          ),
        ),
      ],
    );
  }
}
