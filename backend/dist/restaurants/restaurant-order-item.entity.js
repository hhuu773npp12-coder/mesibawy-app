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
exports.RestaurantOrderItem = void 0;
const typeorm_1 = require("typeorm");
const restaurant_order_entity_1 = require("./restaurant-order.entity");
const restaurant_offer_entity_1 = require("./restaurant-offer.entity");
let RestaurantOrderItem = class RestaurantOrderItem {
    id;
    order;
    offer;
    qty;
    price;
};
exports.RestaurantOrderItem = RestaurantOrderItem;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)('uuid'),
    __metadata("design:type", String)
], RestaurantOrderItem.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => restaurant_order_entity_1.RestaurantOrder, (o) => o.items, { onDelete: 'CASCADE' }),
    __metadata("design:type", restaurant_order_entity_1.RestaurantOrder)
], RestaurantOrderItem.prototype, "order", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => restaurant_offer_entity_1.RestaurantOffer, { eager: true, onDelete: 'RESTRICT' }),
    __metadata("design:type", restaurant_offer_entity_1.RestaurantOffer)
], RestaurantOrderItem.prototype, "offer", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'int' }),
    __metadata("design:type", Number)
], RestaurantOrderItem.prototype, "qty", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'int' }),
    __metadata("design:type", Number)
], RestaurantOrderItem.prototype, "price", void 0);
exports.RestaurantOrderItem = RestaurantOrderItem = __decorate([
    (0, typeorm_1.Entity)({ name: 'restaurant_order_items' })
], RestaurantOrderItem);
//# sourceMappingURL=restaurant-order-item.entity.js.map