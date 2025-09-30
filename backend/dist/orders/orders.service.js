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
exports.OrdersService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const order_entity_1 = require("./order.entity");
const pricing_service_1 = require("../pricing/pricing.service");
const user_entity_1 = require("../users/user.entity");
const restaurant_offer_entity_1 = require("../restaurants/restaurant-offer.entity");
let OrdersService = class OrdersService {
    repo;
    usersRepo;
    offersRepo;
    pricing;
    constructor(repo, usersRepo, offersRepo, pricing) {
        this.repo = repo;
        this.usersRepo = usersRepo;
        this.offersRepo = offersRepo;
        this.pricing = pricing;
    }
    async estimateAndCreate(input) {
        const est = this.pricing.estimate({
            category: input.category,
            distanceKm: input.distanceKm,
            durationMin: input.durationMin,
        });
        let user = null;
        if (input.userId) {
            user = await this.usersRepo.findOne({ where: { id: input.userId } });
            if (!user)
                throw new common_1.NotFoundException('User not found');
        }
        const order = this.repo.create({
            user,
            category: input.category,
            distanceKm: input.distanceKm,
            durationMin: input.durationMin ?? null,
            priceTotal: est.total,
            currency: est.currency,
            breakdown: est.breakdown,
            status: 'CREATED',
        });
        const saved = await this.repo.save(order);
        return { order: saved, estimate: est };
    }
    listAdmin(limit = 100, filters) {
        const where = {};
        if (filters?.category)
            where.category = filters.category;
        if (filters?.status)
            where.status = filters.status;
        const findOpts = {
            where,
            order: { createdAt: 'DESC' },
            take: limit,
        };
        if (filters?.dateFrom || filters?.dateTo) {
            const from = filters?.dateFrom ? new Date(filters.dateFrom) : undefined;
            const to = filters?.dateTo ? new Date(filters.dateTo) : undefined;
            const qb = this.repo.createQueryBuilder('o').leftJoinAndSelect('o.user', 'user');
            qb.orderBy('o.createdAt', 'DESC').limit(limit);
            if (where.category)
                qb.andWhere('o.category = :cat', { cat: where.category });
            if (where.status)
                qb.andWhere('o.status = :st', { st: where.status });
            if (from)
                qb.andWhere('o.createdAt >= :from', { from });
            if (to)
                qb.andWhere('o.createdAt <= :to', { to });
            return qb.getMany();
        }
        return this.repo.find(findOpts);
    }
    async createFoodOrder(userId, input) {
        const user = await this.usersRepo.findOne({ where: { id: userId } });
        if (!user)
            throw new common_1.NotFoundException('User not found');
        const offer = await this.offersRepo.findOne({ where: { id: input.offerId } });
        if (!offer)
            throw new common_1.NotFoundException('Offer not found');
        if (!input.quantity || input.quantity < 1)
            throw new common_1.BadRequestException('Quantity must be >= 1');
        const priceTotal = offer.price * input.quantity;
        const breakdown = {
            kind: 'food',
            offerId: offer.id,
            offerName: offer.name,
            unitPrice: offer.price,
            quantity: input.quantity,
            notes: input.notes ?? null,
            restaurantOwnerId: offer.ownerUserId,
            stage: 'pending',
        };
        const order = this.repo.create({
            user,
            category: 'food',
            distanceKm: 0,
            durationMin: null,
            priceTotal,
            currency: 'IQD',
            breakdown,
            status: 'CREATED',
        });
        return this.repo.save(order);
    }
    async listRestaurantOrders(ownerUserId, stage) {
        const qb = this.repo.createQueryBuilder('o');
        qb.where("o.category = :cat", { cat: 'food' });
        qb.andWhere("(o.breakdown->>'restaurantOwnerId') = :oid", { oid: ownerUserId });
        if (stage)
            qb.andWhere("(o.breakdown->>'stage') = :st", { st: stage });
        qb.orderBy('o.createdAt', 'DESC');
        return qb.getMany();
    }
    async updateRestaurantOrderStage(orderId, stage) {
        const order = await this.repo.findOne({ where: { id: orderId } });
        if (!order)
            throw new common_1.NotFoundException('Order not found');
        if (order.category !== 'food')
            throw new common_1.BadRequestException('Not a food order');
        const breakdown = { ...(order.breakdown || {}) };
        breakdown.stage = stage;
        order.breakdown = breakdown;
        if (stage === 'completed')
            order.status = 'COMPLETED';
        if (stage === 'rejected')
            order.status = 'CANCELLED';
        return this.repo.save(order);
    }
    async getByIdForUser(userId, orderId) {
        const order = await this.repo.findOne({ where: { id: orderId } });
        if (!order)
            throw new common_1.NotFoundException('Order not found');
        if (!order.user || order.user.id !== userId)
            throw new common_1.NotFoundException('Order not found');
        return order;
    }
};
exports.OrdersService = OrdersService;
exports.OrdersService = OrdersService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(order_entity_1.Order)),
    __param(1, (0, typeorm_1.InjectRepository)(user_entity_1.User)),
    __param(2, (0, typeorm_1.InjectRepository)(restaurant_offer_entity_1.RestaurantOffer)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        pricing_service_1.PricingService])
], OrdersService);
//# sourceMappingURL=orders.service.js.map