import { EnergyOfferImage } from './energy-offer-image.entity';
export declare class EnergyOffer {
    id: string;
    title: string;
    brand: string;
    details: string;
    imageUrl?: string | null;
    createdAt: Date;
    images: EnergyOfferImage[];
}
