"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.PricingService = void 0;
const common_1 = require("@nestjs/common");
let PricingService = class PricingService {
    estimate(input) {
        const distance = Math.max(0, Number(input.distanceKm || 0));
        if (!input.category)
            throw new common_1.BadRequestException('category is required');
        const baseByCategory = {
            taxi: 2000,
            tuk_tuk: 1000,
            kia_passenger: 3000,
            kia_haml: 4000,
            stuta: 1000,
            bike: 500,
        };
        const perKmByCategory = {
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
};
exports.PricingService = PricingService;
exports.PricingService = PricingService = __decorate([
    (0, common_1.Injectable)()
], PricingService);
//# sourceMappingURL=pricing.service.js.map