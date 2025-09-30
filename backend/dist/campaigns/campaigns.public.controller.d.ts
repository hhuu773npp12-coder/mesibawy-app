import { CampaignsService } from './campaigns.service';
export declare class CampaignsPublicController {
    private readonly campaigns;
    constructor(campaigns: CampaignsService);
    list(): Promise<import("./campaign.entity").Campaign[]>;
    book(id: string, body: {
        userId: string;
        count?: number;
        originLat?: number;
        originLng?: number;
        destLat?: number;
        destLng?: number;
    }): Promise<{
        ok: boolean;
        bookingIds: string[];
        count: number;
        remaining: number;
    }>;
}
