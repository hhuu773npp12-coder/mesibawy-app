import { Repository } from 'typeorm';
import { WalletTransaction, WalletTxnType } from './wallet-transaction.entity';
import { User } from '../users/user.entity';
import { TopupCard } from '../cards/topup-card.entity';
export declare class WalletsService {
    private readonly txRepo;
    private readonly usersRepo;
    private readonly cardsRepo;
    constructor(txRepo: Repository<WalletTransaction>, usersRepo: Repository<User>, cardsRepo: Repository<TopupCard>);
    getBalance(userId: string): Promise<{
        balance: number;
    }>;
    listTransactions(userId: string): Promise<WalletTransaction[]>;
    addTransaction(userId: string, amount: number, type: WalletTxnType, reference?: string): Promise<{
        balance: number;
        transaction: WalletTransaction;
    }>;
    topupByCode(userId: string, code: string): Promise<{
        balance: number;
        added: number;
    }>;
}
