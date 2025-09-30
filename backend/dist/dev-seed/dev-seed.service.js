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
var DevSeedService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.DevSeedService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const user_entity_1 = require("../users/user.entity");
const restaurant_offer_entity_1 = require("../restaurants/restaurant-offer.entity");
const topup_card_entity_1 = require("../cards/topup-card.entity");
let DevSeedService = DevSeedService_1 = class DevSeedService {
    usersRepo;
    offersRepo;
    cardsRepo;
    logger = new common_1.Logger(DevSeedService_1.name);
    constructor(usersRepo, offersRepo, cardsRepo) {
        this.usersRepo = usersRepo;
        this.offersRepo = offersRepo;
        this.cardsRepo = cardsRepo;
    }
    async onApplicationBootstrap() {
        if (process.env.ENABLE_DEV_SEED !== 'true') {
            this.logger.log('Dev seed is disabled. Set ENABLE_DEV_SEED=true to enable.');
            return;
        }
        this.logger.log('Running development seed...');
        let owner = await this.usersRepo.findOne({ where: { role: 'owner' } });
        if (!owner) {
            owner = this.usersRepo.create({
                phone: '0000000000',
                name: 'Owner',
                role: 'owner',
                userId: `U${Date.now().toString(36).toUpperCase()}`,
                isApproved: true,
                isActive: true,
                walletBalance: 200000,
            });
            owner = await this.usersRepo.save(owner);
            this.logger.log(`Created owner user: ${owner.id}`);
        }
        const existingOffers = await this.offersRepo.count();
        if (existingOffers === 0) {
            const samples = [
                { ownerUserId: owner.id, name: 'بيتزا', price: 8000, imageUrl: 'https://picsum.photos/seed/pizza/400', restaurantLat: 33.34, restaurantLng: 44.39 },
                { ownerUserId: owner.id, name: 'برغر', price: 6000, imageUrl: 'https://picsum.photos/seed/burger/400', restaurantLat: 33.35, restaurantLng: 44.38 },
            ];
            const entities = this.offersRepo.create(samples);
            await this.offersRepo.save(entities);
            this.logger.log('Seeded restaurant offers.');
        }
        const cardsCount = await this.cardsRepo.count();
        if (cardsCount === 0) {
            const toCreate = [];
            for (let i = 0; i < 5; i++) {
                toCreate.push(this.cardsRepo.create({ code: this.generateCode(10), amount: 10000, used: false }));
            }
            await this.cardsRepo.save(toCreate);
            this.logger.log('Seeded topup cards.');
        }
        this.logger.log('Development seed completed.');
    }
    generateCode(len) {
        let s = '';
        for (let i = 0; i < len; i++)
            s += Math.floor(Math.random() * 10).toString();
        return s;
    }
};
exports.DevSeedService = DevSeedService;
exports.DevSeedService = DevSeedService = DevSeedService_1 = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(user_entity_1.User)),
    __param(1, (0, typeorm_1.InjectRepository)(restaurant_offer_entity_1.RestaurantOffer)),
    __param(2, (0, typeorm_1.InjectRepository)(topup_card_entity_1.TopupCard)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository])
], DevSeedService);
//# sourceMappingURL=dev-seed.service.js.map