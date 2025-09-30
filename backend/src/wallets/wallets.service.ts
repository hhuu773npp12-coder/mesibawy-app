import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { WalletTransaction, WalletTxnType } from './wallet-transaction.entity';
import { User } from '../users/user.entity';
import { TopupCard } from '../cards/topup-card.entity';

@Injectable()
export class WalletsService {
  constructor(
    @InjectRepository(WalletTransaction)
    private readonly txRepo: Repository<WalletTransaction>,
    @InjectRepository(User)
    private readonly usersRepo: Repository<User>,
    @InjectRepository(TopupCard)
    private readonly cardsRepo: Repository<TopupCard>,
  ) {}

  async getBalance(userId: string): Promise<{ balance: number }> {
    const user = await this.usersRepo.findOne({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');
    return { balance: user.walletBalance };
  }

  async listTransactions(userId: string): Promise<WalletTransaction[]> {
    const user = await this.usersRepo.findOne({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');
    return this.txRepo.find({ where: { user }, order: { createdAt: 'DESC' } });
  }

  async addTransaction(
    userId: string,
    amount: number,
    type: WalletTxnType,
    reference?: string,
  ): Promise<{ balance: number; transaction: WalletTransaction }> {
    const user = await this.usersRepo.findOne({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');

    user.walletBalance = (user.walletBalance || 0) + amount;
    await this.usersRepo.save(user);

    const tx = this.txRepo.create({ user, amount, type, reference: reference ?? null });
    const transaction = await this.txRepo.save(tx);

    return { balance: user.walletBalance, transaction };
  }

  async topupByCode(userId: string, code: string): Promise<{ balance: number; added: number }> {
    const user = await this.usersRepo.findOne({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');

    const normalized = (code || '').trim();
    // Find unused card in DB
    const card = await this.cardsRepo.findOne({ where: { code: normalized, used: false } });
    if (!card) {
      throw new Error('Invalid or used topup code');
    }
    // Mark card as used by this user
    card.used = true;
    card.usedByUserId = userId;
    await this.cardsRepo.save(card);

    const amount = Math.max(0, card.amount || 0);
    const { balance } = await this.addTransaction(userId, amount, 'TOPUP', normalized);
    return { balance, added: amount };
  }
}
