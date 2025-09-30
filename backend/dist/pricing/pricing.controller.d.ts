import { PricingService } from './pricing.service';
import { EstimateDto } from './dto/estimate.dto';
export declare class PricingController {
    private readonly pricing;
    constructor(pricing: PricingService);
    estimate(body: EstimateDto): {
        category: import("./pricing.service").Category;
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
