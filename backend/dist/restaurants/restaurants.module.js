"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.RestaurantsModule = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const restaurant_offer_entity_1 = require("./restaurant-offer.entity");
const restaurant_order_entity_1 = require("./restaurant-order.entity");
const restaurant_order_item_entity_1 = require("./restaurant-order-item.entity");
const restaurants_service_1 = require("./restaurants.service");
const restaurants_controller_1 = require("./restaurants.controller");
const restaurants_public_controller_1 = require("./restaurants.public.controller");
const auth_module_1 = require("../auth/auth.module");
let RestaurantsModule = class RestaurantsModule {
};
exports.RestaurantsModule = RestaurantsModule;
exports.RestaurantsModule = RestaurantsModule = __decorate([
    (0, common_1.Module)({
        imports: [typeorm_1.TypeOrmModule.forFeature([restaurant_offer_entity_1.RestaurantOffer, restaurant_order_entity_1.RestaurantOrder, restaurant_order_item_entity_1.RestaurantOrderItem]), auth_module_1.AuthModule],
        controllers: [restaurants_controller_1.RestaurantsController, restaurants_public_controller_1.RestaurantsPublicController],
        providers: [restaurants_service_1.RestaurantsService],
        exports: [restaurants_service_1.RestaurantsService],
    })
], RestaurantsModule);
//# sourceMappingURL=restaurants.module.js.map