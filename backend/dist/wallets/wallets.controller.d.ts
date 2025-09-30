import { WalletsService } from './wallets.service';
export declare class WalletsController {
    private readonly wallets;
    constructor(wallets: WalletsService);
    getBalance(userId: string): Promise<{
        balance: number;
    }>;
    list(userId: string): Promise<import("./wallet-transaction.entity").WalletTransaction[]>;
    credit(userId: string, body: {
        amount: number;
        reference?: string;
    }): Promise<{
        balance: number;
        transaction: import("./wallet-transaction.entity").WalletTransaction;
    }>;
    debit(userId: string, body: {
        amount: number;
        reference?: string;
    }): Promise<{
        balance: number;
        transaction: import("./wallet-transaction.entity").WalletTransaction;
    }>;
    topupMe(req: any, body: {
        code: string;
    }): Promise<{
        balance: number;
        added: number;
    }>;
}
