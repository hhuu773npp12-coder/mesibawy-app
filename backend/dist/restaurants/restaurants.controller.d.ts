import { RestaurantsService } from './restaurants.service';
import type { RestaurantOrderStage } from './restaurant-order.entity';
export declare class RestaurantsController {
    private readonly restaurants;
    constructor(restaurants: RestaurantsService);
    listMy(req: any): Promise<import("./restaurant-offer.entity").RestaurantOffer[]>;
    create(req: any, body: {
        name: string;
        price: number;
        imageUrl: string;
    }): Promise<import("./restaurant-offer.entity").RestaurantOffer>;
    listOrders(req: any, stage?: RestaurantOrderStage): Promise<import("./restaurant-order.entity").RestaurantOrder[]>;
    updateOrderStage(req: any, id: string, body: {
        stage: RestaurantOrderStage;
    }): Promise<{
        ok: boolean;
    }>;
}
