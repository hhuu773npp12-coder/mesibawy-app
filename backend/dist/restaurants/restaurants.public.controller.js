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
exports.RestaurantsPublicController = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const restaurant_offer_entity_1 = require("./restaurant-offer.entity");
const restaurants_service_1 = require("./restaurants.service");
let RestaurantsPublicController = class RestaurantsPublicController {
    offersRepo;
    restaurants;
    constructor(offersRepo, restaurants) {
        this.offersRepo = offersRepo;
        this.restaurants = restaurants;
    }
    listAll() {
        return this.offersRepo.find({ order: { createdAt: 'DESC' }, take: 200 });
    }
    createOrder(body) {
        return this.restaurants.createPublicOrder(body);
    }
};
exports.RestaurantsPublicController = RestaurantsPublicController;
__decorate([
    (0, common_1.Get)('offers'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], RestaurantsPublicController.prototype, "listAll", null);
__decorate([
    (0, common_1.Post)('orders'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], RestaurantsPublicController.prototype, "createOrder", null);
exports.RestaurantsPublicController = RestaurantsPublicController = __decorate([
    (0, common_1.Controller)('public/restaurant'),
    __param(0, (0, typeorm_1.InjectRepository)(restaurant_offer_entity_1.RestaurantOffer)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        restaurants_service_1.RestaurantsService])
], RestaurantsPublicController);
//# sourceMappingURL=restaurants.public.controller.js.map