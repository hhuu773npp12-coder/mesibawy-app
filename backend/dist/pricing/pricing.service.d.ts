export type Category = 'taxi' | 'tuk_tuk' | 'kia_passenger' | 'kia_haml' | 'stuta' | 'bike';
export interface EstimateInput {
    category: Category;
    distanceKm: number;
    durationMin?: number;
}
export declare class PricingService {
    estimate(input: EstimateInput): {
        category: Category;
        distanceKm: number;
        breakdown: {
            base: number;
            perKm: number;
            distanceCost: number;
        };
        total: number;
        currency: string;
    };
}
