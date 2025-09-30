"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.DevSeedModule = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const dev_seed_service_1 = require("./dev-seed.service");
const user_entity_1 = require("../users/user.entity");
const restaurant_offer_entity_1 = require("../restaurants/restaurant-offer.entity");
const topup_card_entity_1 = require("../cards/topup-card.entity");
let DevSeedModule = class DevSeedModule {
};
exports.DevSeedModule = DevSeedModule;
exports.DevSeedModule = DevSeedModule = __decorate([
    (0, common_1.Module)({
        imports: [typeorm_1.TypeOrmModule.forFeature([user_entity_1.User, restaurant_offer_entity_1.RestaurantOffer, topup_card_entity_1.TopupCard])],
        providers: [dev_seed_service_1.DevSeedService],
    })
], DevSeedModule);
//# sourceMappingURL=dev-seed.module.js.map