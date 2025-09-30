import { Repository } from 'typeorm';
import { EnergyOffer } from './entities/energy-offer.entity';
import { EnergyOfferImage } from './entities/energy-offer-image.entity';
import { EnergyRequest as EnergyRequestEntity } from './entities/energy-request.entity';
import { TopupCard } from '../cards/topup-card.entity';
import { RestaurantSettlement } from './entities/restaurant-settlement.entity';
import { User } from '../users/user.entity';
export declare class OwnerService {
    private readonly offersRepo;
    private readonly offerImagesRepo;
    private readonly requestsRepo;
    private readonly cardsRepo;
    private readonly settlementsRepo;
    private readonly usersRepo;
    constructor(offersRepo: Repository<EnergyOffer>, offerImagesRepo: Repository<EnergyOfferImage>, requestsRepo: Repository<EnergyRequestEntity>, cardsRepo: Repository<TopupCard>, settlementsRepo: Repository<RestaurantSettlement>, usersRepo: Repository<User>);
    getWallet(): Promise<{
        balance: number;
    }>;
    addToWallet(amount: number): Promise<{
        balance: number;
    }>;
    private genId;
    private genDigits;
    listTopupCards(): Promise<TopupCard[]>;
    generateTopupCards(count: number): Promise<{
        created: number;
        cost: number;
        balance: number;
    }>;
    listRestaurantSettlements(): Promise<RestaurantSettlement[]>;
    markSettlementPaid(id: string): Promise<{
        ok: boolean;
    }>;
    createEnergyOffer(input: {
        title: string;
        brand: string;
        details: string;
        imageUrl?: string;
        images?: string[];
    }): Promise<EnergyOffer | null>;
    listEnergyRequests(): Promise<EnergyRequestEntity[]>;
    listPublicEnergyOffers(): Promise<EnergyOffer[]>;
    createEnergyRequest(input: {
        name: string;
        phone: string;
        location?: string;
        lat?: number;
        lng?: number;
        offerId?: string;
    }): Promise<EnergyRequestEntity>;
    private getOrCreateOwner;
}
