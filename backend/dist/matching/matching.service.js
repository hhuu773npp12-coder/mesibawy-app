"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.MatchingService = void 0;
const common_1 = require("@nestjs/common");
let MatchingService = class MatchingService {
    distanceKm(aLat, aLng, bLat, bLng) {
        const toRad = (d) => (d * Math.PI) / 180;
        const R = 6371;
        const dLat = toRad(bLat - aLat);
        const dLon = toRad(bLng - aLng);
        const lat1 = toRad(aLat);
        const lat2 = toRad(bLat);
        const h = Math.sin(dLat / 2) ** 2 + Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLon / 2) ** 2;
        return 2 * R * Math.asin(Math.min(1, Math.sqrt(h)));
    }
    filterAndRankCandidates(cands, opts) {
        const maxRadiusKm = opts.maxRadiusKm ?? 15;
        const minWallet = opts.minWallet ?? 0;
        const limit = opts.limit ?? 10;
        const enriched = [];
        for (const c of cands) {
            if (!c.active)
                continue;
            if (c.walletBalance < minWallet)
                continue;
            if (typeof c.lat !== 'number' || typeof c.lng !== 'number')
                continue;
            const dist = this.distanceKm(opts.jobLat, opts.jobLng, c.lat, c.lng);
            if (dist > maxRadiusKm)
                continue;
            enriched.push({ ...c, distanceKm: +dist.toFixed(3) });
        }
        enriched.sort((a, b) => {
            if (a.distanceKm !== b.distanceKm)
                return a.distanceKm - b.distanceKm;
            return b.walletBalance - a.walletBalance;
        });
        return enriched.slice(0, Math.max(1, limit));
    }
};
exports.MatchingService = MatchingService;
exports.MatchingService = MatchingService = __decorate([
    (0, common_1.Injectable)()
], MatchingService);
//# sourceMappingURL=matching.service.js.map