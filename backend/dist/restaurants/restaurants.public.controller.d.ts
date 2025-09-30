import { Repository } from 'typeorm';
import { RestaurantOffer } from './restaurant-offer.entity';
import { RestaurantsService } from './restaurants.service';
export declare class RestaurantsPublicController {
    private readonly offersRepo;
    private readonly restaurants;
    constructor(offersRepo: Repository<RestaurantOffer>, restaurants: RestaurantsService);
    listAll(): Promise<RestaurantOffer[]>;
    createOrder(body: {
        customerName?: string;
        customerPhone?: string;
        items: {
            offerId: string;
            qty: number;
        }[];
        distanceKm?: number;
        restaurantLat?: number;
        restaurantLng?: number;
        customerLat?: number;
        customerLng?: number;
    }): Promise<import("./restaurant-order.entity").RestaurantOrder>;
}
