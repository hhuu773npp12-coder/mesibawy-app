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
exports.EnergyRequest = void 0;
const typeorm_1 = require("typeorm");
const energy_offer_entity_1 = require("./energy-offer.entity");
let EnergyRequest = class EnergyRequest {
    id;
    name;
    phone;
    location;
    lat;
    lng;
    createdAt;
    offer;
};
exports.EnergyRequest = EnergyRequest;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)('uuid'),
    __metadata("design:type", String)
], EnergyRequest.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'varchar', length: 120 }),
    __metadata("design:type", String)
], EnergyRequest.prototype, "name", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'varchar', length: 30 }),
    __metadata("design:type", String)
], EnergyRequest.prototype, "phone", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'varchar', length: 200, nullable: true }),
    __metadata("design:type", Object)
], EnergyRequest.prototype, "location", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'double precision', nullable: true }),
    __metadata("design:type", Object)
], EnergyRequest.prototype, "lat", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'double precision', nullable: true }),
    __metadata("design:type", Object)
], EnergyRequest.prototype, "lng", void 0);
__decorate([
    (0, typeorm_1.CreateDateColumn)({ type: 'timestamp with time zone' }),
    __metadata("design:type", Date)
], EnergyRequest.prototype, "createdAt", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => energy_offer_entity_1.EnergyOffer, { nullable: true, onDelete: 'SET NULL' }),
    __metadata("design:type", Object)
], EnergyRequest.prototype, "offer", void 0);
exports.EnergyRequest = EnergyRequest = __decorate([
    (0, typeorm_1.Entity)({ name: 'energy_requests' })
], EnergyRequest);
//# sourceMappingURL=energy-request.entity.js.map