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
exports.RestaurantOrder = void 0;
const typeorm_1 = require("typeorm");
const restaurant_order_item_entity_1 = require("./restaurant-order-item.entity");
let RestaurantOrder = class RestaurantOrder {
    id;
    ownerUserId;
    customerName;
    customerPhone;
    stage;
    itemsTotal;
    commission;
    delivery;
    createdAt;
    items;
};
exports.RestaurantOrder = RestaurantOrder;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)('uuid'),
    __metadata("design:type", String)
], RestaurantOrder.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'uuid' }),
    __metadata("design:type", String)
], RestaurantOrder.prototype, "ownerUserId", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'varchar', length: 120, nullable: true }),
    __metadata("design:type", Object)
], RestaurantOrder.prototype, "customerName", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'varchar', length: 30, nullable: true }),
    __metadata("design:type", Object)
], RestaurantOrder.prototype, "customerPhone", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'varchar', length: 32 }),
    __metadata("design:type", String)
], RestaurantOrder.prototype, "stage", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'int', default: 0 }),
    __metadata("design:type", Number)
], RestaurantOrder.prototype, "itemsTotal", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'int', default: 0 }),
    __metadata("design:type", Number)
], RestaurantOrder.prototype, "commission", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'int', default: 0 }),
    __metadata("design:type", Number)
], RestaurantOrder.prototype, "delivery", void 0);
__decorate([
    (0, typeorm_1.CreateDateColumn)(),
    __metadata("design:type", Date)
], RestaurantOrder.prototype, "createdAt", void 0);
__decorate([
    (0, typeorm_1.OneToMany)(() => restaurant_order_item_entity_1.RestaurantOrderItem, (it) => it.order, { cascade: true }),
    __metadata("design:type", Array)
], RestaurantOrder.prototype, "items", void 0);
exports.RestaurantOrder = RestaurantOrder = __decorate([
    (0, typeorm_1.Entity)({ name: 'restaurant_orders' })
], RestaurantOrder);
//# sourceMappingURL=restaurant-order.entity.js.map