"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.EnergyOfferImage = void 0;
const typeorm_1 = require("typeorm");
const energy_offer_entity_1 = require("./energy-offer.entity");
let EnergyOfferImage = class EnergyOfferImage {
    id;
    url;
    offer;
};
exports.EnergyOfferImage = EnergyOfferImage;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)('uuid'),
    __metadata("design:type", String)
], EnergyOfferImage.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'varchar', length: 500 }),
    __metadata("design:type", String)
], EnergyOfferImage.prototype, "url", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => energy_offer_entity_1.EnergyOffer, (offer) => offer.images, { onDelete: 'CASCADE' }),
    __metadata("design:type", energy_offer_entity_1.EnergyOffer)
], EnergyOfferImage.prototype, "offer", void 0);
exports.EnergyOfferImage = EnergyOfferImage = __decorate([
    (0, typeorm_1.Entity)({ name: 'energy_offer_images' })
], EnergyOfferImage);
//# sourceMappingURL=energy-offer-image.entity.js.map