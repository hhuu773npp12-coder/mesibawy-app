import { EnergyOffer } from './energy-offer.entity';
export declare class EnergyRequest {
    id: string;
    name: string;
    phone: string;
    location?: string | null;
    lat?: number | null;
    lng?: number | null;
    createdAt: Date;
    offer?: EnergyOffer | null;
}
