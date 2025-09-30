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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.OwnerController = void 0;
const common_1 = require("@nestjs/common");
const owner_service_1 = require("./owner.service");
let OwnerController = class OwnerController {
    owner;
    constructor(owner) {
        this.owner = owner;
    }
    getWallet() {
        return this.owner.getWallet();
    }
    generateCards(body) {
        return this.owner.generateTopupCards(body.count);
    }
    listCards() {
        return this.owner.listTopupCards();
    }
    listSettlements() {
        return this.owner.listRestaurantSettlements();
    }
    markPaid(id) {
        return this.owner.markSettlementPaid(id);
    }
    async createEnergyOffer(body) {
        return await this.owner.createEnergyOffer(body);
    }
    listEnergyRequests() {
        return this.owner.listEnergyRequests();
    }
    listPublicEnergyOffers() {
        return this.owner.listPublicEnergyOffers();
    }
    createPublicEnergyRequest(body) {
        return this.owner.createEnergyRequest(body);
    }
};
exports.OwnerController = OwnerController;
__decorate([
    (0, common_1.Get)('wallet'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], OwnerController.prototype, "getWallet", null);
__decorate([
    (0, common_1.Post)('topup-cards/generate'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], OwnerController.prototype, "generateCards", null);
__decorate([
    (0, common_1.Get)('topup-cards'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], OwnerController.prototype, "listCards", null);
__decorate([
    (0, common_1.Get)('restaurant-settlements'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], OwnerController.prototype, "listSettlements", null);
__decorate([
    (0, common_1.Post)('restaurant-settlements/:id/pay'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], OwnerController.prototype, "markPaid", null);
__decorate([
    (0, common_1.Post)('energy/offers'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], OwnerController.prototype, "createEnergyOffer", null);
__decorate([
    (0, common_1.Get)('energy/requests'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], OwnerController.prototype, "listEnergyRequests", null);
__decorate([
    (0, common_1.Get)('public/energy/offers'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], OwnerController.prototype, "listPublicEnergyOffers", null);
__decorate([
    (0, common_1.Post)('public/energy/requests'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], OwnerController.prototype, "createPublicEnergyRequest", null);
exports.OwnerController = OwnerController = __decorate([
    (0, common_1.Controller)('owner'),
    __metadata("design:paramtypes", [owner_service_1.OwnerService])
], OwnerController);
//# sourceMappingURL=owner.controller.js.map