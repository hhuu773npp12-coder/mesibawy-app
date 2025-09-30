import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { TopupCard } from './topup-card.entity';
import { User } from '../users/user.entity';
import { WalletsService } from '../wallets/wallets.service';

@Injectable()
export class CardsService {
  constructor(
    @InjectRepository(TopupCard)
    private readonly cardsRepo: Repository<TopupCard>,
    @InjectRepository(User)
    private readonly usersRepo: Repository<User>,
    private readonly wallets: WalletsService,
  ) {}

  async createBatch(count: number, amount = 10000): Promise<TopupCard[]> {
    const cards: TopupCard[] = [];
    for (let i = 0; i < count; i++) {
      const code = this.generateCode();
      const card = this.cardsRepo.create({ code, amount });
      cards.push(card);
    }
    return this.cardsRepo.save(cards);
  }

  async list(): Promise<TopupCard[]> {
    return this.cardsRepo.find({ order: { createdAt: 'DESC' } });
  }

  async redeem(code: string, userId: string) {
    const card = await this.cardsRepo.findOne({ where: { code } });
    if (!card) throw new NotFoundException('Card not found');
    if (card.used) throw new BadRequestException('Card already used');

    const user = await this.usersRepo.findOne({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');

    // Mark used first to avoid race conditions (ideally within a transaction)
    card.used = true;
    card.usedByUserId = user.id;
    await this.cardsRepo.save(card);

    // Credit wallet
    return this.wallets.addTransaction(user.id, card.amount, 'TOPUP', `CARD:${card.code}`);
  }

  private generateCode(): string {
    // 10-char alphanumeric code, avoiding ambiguous chars
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    let out = '';
    for (let i = 0; i < 10; i++) {
      out += alphabet[Math.floor(Math.random() * alphabet.length)];
    }
    return out;
  }
}
