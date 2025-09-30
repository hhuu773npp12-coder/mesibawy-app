import { Repository } from 'typeorm';
import { TopupCard } from './topup-card.entity';
import { User } from '../users/user.entity';
import { WalletsService } from '../wallets/wallets.service';
export declare class CardsService {
    private readonly cardsRepo;
    private readonly usersRepo;
    private readonly wallets;
    constructor(cardsRepo: Repository<TopupCard>, usersRepo: Repository<User>, wallets: WalletsService);
    createBatch(count: number, amount?: number): Promise<TopupCard[]>;
    list(): Promise<TopupCard[]>;
    redeem(code: string, userId: string): Promise<{
        balance: number;
        transaction: import("../wallets/wallet-transaction.entity").WalletTransaction;
    }>;
    private generateCode;
}
