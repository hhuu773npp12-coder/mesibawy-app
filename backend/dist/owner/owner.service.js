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
exports.OwnerService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const energy_offer_entity_1 = require("./entities/energy-offer.entity");
const energy_offer_image_entity_1 = require("./entities/energy-offer-image.entity");
const energy_request_entity_1 = require("./entities/energy-request.entity");
const topup_card_entity_1 = require("../cards/topup-card.entity");
const restaurant_settlement_entity_1 = require("./entities/restaurant-settlement.entity");
const user_entity_1 = require("../users/user.entity");
let OwnerService = class OwnerService {
    offersRepo;
    offerImagesRepo;
    requestsRepo;
    cardsRepo;
    settlementsRepo;
    usersRepo;
    constructor(offersRepo, offerImagesRepo, requestsRepo, cardsRepo, settlementsRepo, usersRepo) {
        this.offersRepo = offersRepo;
        this.offerImagesRepo = offerImagesRepo;
        this.requestsRepo = requestsRepo;
        this.cardsRepo = cardsRepo;
        this.settlementsRepo = settlementsRepo;
        this.usersRepo = usersRepo;
    }
    async getWallet() {
        const owner = await this.getOrCreateOwner();
        return { balance: owner.walletBalance };
    }
    async addToWallet(amount) {
        if (!Number.isFinite(amount) || amount === 0) {
            const owner = await this.getOrCreateOwner();
            return { balance: owner.walletBalance };
        }
        const owner = await this.getOrCreateOwner();
        owner.walletBalance = Math.max(0, (owner.walletBalance || 0) + Math.floor(amount));
        await this.usersRepo.save(owner);
        return { balance: owner.walletBalance };
    }
    genId(prefix) {
        return prefix + Math.random().toString(36).substring(2, 10);
    }
    genDigits(len) {
        let s = '';
        for (let i = 0; i < len; i++)
            s += Math.floor(Math.random() * 10).toString();
        return s;
    }
    listTopupCards() {
        return this.cardsRepo.find({ order: { updatedAt: 'DESC' } });
    }
    async generateTopupCards(count) {
        if (!Number.isFinite(count) || count <= 0)
            throw new common_1.BadRequestException('Invalid count');
        const pricePerCard = 10_000;
        const totalCost = pricePerCard * count;
        const owner = await this.getOrCreateOwner();
        if ((owner.walletBalance || 0) < totalCost)
            throw new common_1.BadRequestException('Insufficient wallet balance');
        const entities = [];
        for (let i = 0; i < count; i++) {
            const code = this.genDigits(10);
            const card = this.cardsRepo.create({ code, amount: pricePerCard, used: false });
            entities.push(card);
        }
        const saved = await this.cardsRepo.save(entities);
        owner.walletBalance = Math.max(0, (owner.walletBalance || 0) - totalCost);
        await this.usersRepo.save(owner);
        return { created: saved.length, cost: totalCost, balance: owner.walletBalance };
    }
    listRestaurantSettlements() {
        return this.settlementsRepo.find({ order: { updatedAt: 'DESC' } });
    }
    async markSettlementPaid(id) {
        const s = await this.settlementsRepo.findOne({ where: { id } });
        if (!s)
            throw new common_1.BadRequestException('Not found');
        s.paidAt = new Date();
        s.dueAmount = 0;
        await this.settlementsRepo.save(s);
        return { ok: true };
    }
    async createEnergyOffer(input) {
        const offer = this.offersRepo.create({
            title: input.title,
            brand: input.brand,
            details: input.details,
            imageUrl: input.imageUrl ?? (input.images && input.images.length ? input.images[0] : undefined),
        });
        const saved = await this.offersRepo.save(offer);
        if (input.images && input.images.length) {
            const imgs = input.images.map((url) => this.offerImagesRepo.create({ url, offer: saved }));
            await this.offerImagesRepo.save(imgs);
        }
        return this.offersRepo.findOne({ where: { id: saved.id }, relations: { images: true } });
    }
    listEnergyRequests() {
        return this.requestsRepo.find({ order: { createdAt: 'DESC' } });
    }
    listPublicEnergyOffers() {
        return this.offersRepo.find({ order: { createdAt: 'DESC' }, relations: { images: true } });
    }
    async createEnergyRequest(input) {
        const entity = this.requestsRepo.create({
            name: input.name,
            phone: input.phone,
            location: input.location ?? (input.lat != null && input.lng != null ? `${input.lat},${input.lng}` : undefined),
        });
        if (input.offerId) {
            entity.offer = { id: input.offerId };
        }
        return this.requestsRepo.save(entity);
    }
    async getOrCreateOwner() {
        let owner = await this.usersRepo.findOne({ where: { role: 'owner' }, order: { createdAt: 'ASC' } });
        if (!owner) {
            owner = this.usersRepo.create({
                phone: '0000000000',
                name: 'Owner',
                role: 'owner',
                userId: `U${Date.now().toString(36).toUpperCase()}`,
                isApproved: true,
                isActive: true,
                walletBalance: 0,
            });
            owner = await this.usersRepo.save(owner);
        }
        return owner;
    }
};
exports.OwnerService = OwnerService;
exports.OwnerService = OwnerService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(energy_offer_entity_1.EnergyOffer)),
    __param(1, (0, typeorm_1.InjectRepository)(energy_offer_image_entity_1.EnergyOfferImage)),
    __param(2, (0, typeorm_1.InjectRepository)(energy_request_entity_1.EnergyRequest)),
    __param(3, (0, typeorm_1.InjectRepository)(topup_card_entity_1.TopupCard)),
    __param(4, (0, typeorm_1.InjectRepository)(restaurant_settlement_entity_1.RestaurantSettlement)),
    __param(5, (0, typeorm_1.InjectRepository)(user_entity_1.User)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository])
], OwnerService);
//# sourceMappingURL=owner.service.js.map