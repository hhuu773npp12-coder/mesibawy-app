"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.OwnerModule = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const owner_controller_1 = require("./owner.controller");
const owner_service_1 = require("./owner.service");
const energy_offer_entity_1 = require("./entities/energy-offer.entity");
const energy_offer_image_entity_1 = require("./entities/energy-offer-image.entity");
const energy_request_entity_1 = require("./entities/energy-request.entity");
const topup_card_entity_1 = require("../cards/topup-card.entity");
const restaurant_settlement_entity_1 = require("./entities/restaurant-settlement.entity");
const user_entity_1 = require("../users/user.entity");
let OwnerModule = class OwnerModule {
};
exports.OwnerModule = OwnerModule;
exports.OwnerModule = OwnerModule = __decorate([
    (0, common_1.Module)({
        imports: [typeorm_1.TypeOrmModule.forFeature([energy_offer_entity_1.EnergyOffer, energy_offer_image_entity_1.EnergyOfferImage, energy_request_entity_1.EnergyRequest, topup_card_entity_1.TopupCard, restaurant_settlement_entity_1.RestaurantSettlement, user_entity_1.User])],
        controllers: [owner_controller_1.OwnerController],
        providers: [owner_service_1.OwnerService],
        exports: [owner_service_1.OwnerService],
    })
], OwnerModule);
//# sourceMappingURL=owner.module.js.map