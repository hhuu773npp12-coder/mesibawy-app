import { Repository } from 'typeorm';
import { RestaurantOffer } from './restaurant-offer.entity';
import { RestaurantOrder, RestaurantOrderStage } from './restaurant-order.entity';
import { RestaurantOrderItem } from './restaurant-order-item.entity';
export declare class RestaurantsService {
    private readonly offersRepo;
    private readonly ordersRepo;
    private readonly orderItemsRepo;
    constructor(offersRepo: Repository<RestaurantOffer>, ordersRepo: Repository<RestaurantOrder>, orderItemsRepo: Repository<RestaurantOrderItem>);
    listMyOffers(ownerUserId: string): Promise<RestaurantOffer[]>;
    createOffer(ownerUserId: string, dto: {
        name: string;
        price: number;
        imageUrl: string;
    }): Promise<RestaurantOffer>;
    private computeDelivery;
    private haversineKm;
    createPublicOrder(input: {
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
    }): Promise<RestaurantOrder>;
    listOrders(ownerUserId: string, stage?: RestaurantOrderStage): Promise<RestaurantOrder[]>;
    updateOrderStage(ownerUserId: string, id: string, stage: RestaurantOrderStage): Promise<{
        ok: boolean;
    }>;
}
