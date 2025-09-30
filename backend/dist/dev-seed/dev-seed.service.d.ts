import { OnApplicationBootstrap } from '@nestjs/common';
import { Repository } from 'typeorm';
import { User } from '../users/user.entity';
import { RestaurantOffer } from '../restaurants/restaurant-offer.entity';
import { TopupCard } from '../cards/topup-card.entity';
export declare class DevSeedService implements OnApplicationBootstrap {
    private readonly usersRepo;
    private readonly offersRepo;
    private readonly cardsRepo;
    private readonly logger;
    constructor(usersRepo: Repository<User>, offersRepo: Repository<RestaurantOffer>, cardsRepo: Repository<TopupCard>);
    onApplicationBootstrap(): Promise<void>;
    private generateCode;
}
