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
exports.RestaurantsService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const restaurant_offer_entity_1 = require("./restaurant-offer.entity");
const restaurant_order_entity_1 = require("./restaurant-order.entity");
const restaurant_order_item_entity_1 = require("./restaurant-order-item.entity");
let RestaurantsService = class RestaurantsService {
    offersRepo;
    ordersRepo;
    orderItemsRepo;
    constructor(offersRepo, ordersRepo, orderItemsRepo) {
        this.offersRepo = offersRepo;
        this.ordersRepo = ordersRepo;
        this.orderItemsRepo = orderItemsRepo;
    }
    listMyOffers(ownerUserId) {
        return this.offersRepo.find({ where: { ownerUserId }, order: { createdAt: 'DESC' } });
    }
    async createOffer(ownerUserId, dto) {
        const entity = this.offersRepo.create({ ownerUserId, name: dto.name, price: dto.price, imageUrl: dto.imageUrl });
        return this.offersRepo.save(entity);
    }
    computeDelivery(distanceKm) {
        if (!Number.isFinite(distanceKm) || distanceKm <= 0)
            return 0;
        if (distanceKm <= 3)
            return 1000;
        if (distanceKm <= 5)
            return 2000;
        if (distanceKm <= 8)
            return 3000;
        if (distanceKm <= 12)
            return 4000;
        if (distanceKm <= 15)
            return 5000;
        const extraBlocks = Math.ceil((distanceKm - 15) / 3);
        return 5000 + extraBlocks * 500;
    }
    haversineKm(aLat, aLng, bLat, bLng) {
        const toRad = (d) => (d * Math.PI) / 180;
        const R = 6371;
        const dLat = toRad(bLat - aLat);
        const dLng = toRad(bLng - aLng);
        const lat1 = toRad(aLat);
        const lat2 = toRad(bLat);
        const h = Math.sin(dLat / 2) ** 2 + Math.sin(dLng / 2) ** 2 * Math.cos(lat1) * Math.cos(lat2);
        return 2 * R * Math.asin(Math.sqrt(h));
    }
    async createPublicOrder(input) {
        if (!input.items || !input.items.length)
            throw new common_1.BadRequestException('No items');
        const offerIds = input.items.map((i) => i.offerId);
        const offers = await this.offersRepo.findByIds(offerIds);
        if (offers.length !== offerIds.length)
            throw new common_1.BadRequestException('Invalid offer');
        const ownerUserId = offers[0].ownerUserId;
        if (!offers.every((o) => o.ownerUserId === ownerUserId))
            throw new common_1.BadRequestException('Items must belong to the same restaurant');
        const items = [];
        let itemsTotal = 0;
        for (const it of input.items) {
            const offer = offers.find((o) => o.id === it.offerId);
            const qty = Math.max(1, Math.floor(it.qty));
            const price = offer.price;
            itemsTotal += price * qty;
            items.push(this.orderItemsRepo.create({ offer, qty, price }));
        }
        let delivery = 0;
        if (Number.isFinite(input?.distanceKm)) {
            delivery = this.computeDelivery(input.distanceKm);
        }
        else if (Number.isFinite(input?.customerLat) &&
            Number.isFinite(input?.customerLng)) {
            const restLat = offers[0].restaurantLat ?? input.restaurantLat;
            const restLng = offers[0].restaurantLng ?? input.restaurantLng;
            if (Number.isFinite(restLat) && Number.isFinite(restLng)) {
                const d = this.haversineKm(restLat, restLng, input.customerLat, input.customerLng);
                delivery = this.computeDelivery(d);
            }
        }
        const commission = Math.round(itemsTotal * 0.10);
        const order = this.ordersRepo.create({
            ownerUserId,
            customerName: input.customerName,
            customerPhone: input.customerPhone,
            stage: 'PENDING',
            itemsTotal,
            commission,
            delivery,
            items,
        });
        return this.ordersRepo.save(order);
    }
    listOrders(ownerUserId, stage) {
        const where = { ownerUserId };
        if (stage)
            where.stage = stage;
        return this.ordersRepo.find({ where, order: { createdAt: 'DESC' }, relations: ['items', 'items.offer'] });
    }
    async updateOrderStage(ownerUserId, id, stage) {
        const order = await this.ordersRepo.findOne({ where: { id, ownerUserId } });
        if (!order)
            throw new common_1.NotFoundException('Order not found');
        order.stage = stage;
        await this.ordersRepo.save(order);
        return { ok: true };
    }
};
exports.RestaurantsService = RestaurantsService;
exports.RestaurantsService = RestaurantsService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(restaurant_offer_entity_1.RestaurantOffer)),
    __param(1, (0, typeorm_1.InjectRepository)(restaurant_order_entity_1.RestaurantOrder)),
    __param(2, (0, typeorm_1.InjectRepository)(restaurant_order_item_entity_1.RestaurantOrderItem)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository])
], RestaurantsService);
//# sourceMappingURL=restaurants.service.js.map