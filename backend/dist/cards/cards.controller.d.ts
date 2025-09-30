import { CardsService } from './cards.service';
export declare class CardsController {
    private readonly cards;
    constructor(cards: CardsService);
    list(): Promise<import("./topup-card.entity").TopupCard[]>;
    createBatch(body: {
        count: number;
        amount?: number;
    }): Promise<import("./topup-card.entity").TopupCard[]>;
    redeem(body: {
        code: string;
        userId: string;
    }): Promise<{
        balance: number;
        transaction: import("../wallets/wallet-transaction.entity").WalletTransaction;
    }>;
}
