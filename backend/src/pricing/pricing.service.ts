import { Injectable, BadRequestException } from '@nestjs/common';

export type Category = 'taxi' | 'tuk_tuk' | 'kia_passenger' | 'kia_haml' | 'stuta' | 'bike';

export interface EstimateInput {
  category: Category;
  distanceKm: number; // المسافة بالكيلومترات
  durationMin?: number; // مدة الرحلة بالدقائق (اختياري)
}

@Injectable()
export class PricingService {
  estimate(input: EstimateInput) {
    const distance = Math.max(0, Number(input.distanceKm || 0));
    if (!input.category) throw new BadRequestException('category is required');

    // قواعد تقريبية؛ تُعدّل لاحقاً حسب سياستك
    const baseByCategory: Record<Category, number> = {
      taxi: 2000,
      tuk_tuk: 1000,
      kia_passenger: 3000,
      kia_haml: 4000,
      stuta: 1000,
      bike: 500,
    };

    const perKmByCategory: Record<Category, number> = {
      taxi: 500,
      tuk_tuk: 300,
      kia_passenger: 400,
      kia_haml: 600,
      stuta: 300,
      bike: 200,
    };

    const base = baseByCategory[input.category];
    const perKm = perKmByCategory[input.category];

    const distanceCost = Math.ceil(distance * perKm);
    const total = base + distanceCost;

    return {
      category: input.category,
      distanceKm: distance,
      breakdown: {
        base,
        perKm,
        distanceCost,
      },
      total,
      currency: 'IQD',
    };
  }
}
