import { User } from '../users/user.entity';
export type WalletTxnType = 'TOPUP' | 'DEBIT' | 'CREDIT' | 'FEE';
export declare class WalletTransaction {
    id: string;
    user: User;
    amount: number;
    type: WalletTxnType;
    reference: string | null;
    createdAt: Date;
}
