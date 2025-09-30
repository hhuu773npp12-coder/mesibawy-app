import { OwnerService } from './owner.service';
export declare class OwnerController {
    private readonly owner;
    constructor(owner: OwnerService);
    getWallet(): any;
    generateCards(body: {
        count: number;
    }): any;
    listCards(): any;
    listSettlements(): any;
    markPaid(id: string): any;
    createEnergyOffer(body: {
        title: string;
        brand: string;
        details: string;
        imageUrl?: string;
        images?: string[];
    }): Promise<import("./entities/energy-offer.entity").EnergyOffer | null>;
    listEnergyRequests(): any;
    listPublicEnergyOffers(): any;
    createPublicEnergyRequest(body: {
        name: string;
        phone: string;
        location?: string;
        lat?: number;
        lng?: number;
        offerId?: string;
    }): any;
}
