import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { EnergyOffer } from './entities/energy-offer.entity';
import { EnergyOfferImage } from './entities/energy-offer-image.entity';
import { EnergyRequest as EnergyRequestEntity } from './entities/energy-request.entity';
import { TopupCard } from '../cards/topup-card.entity';
import { RestaurantSettlement } from './entities/restaurant-settlement.entity';
import { User } from '../users/user.entity';

// moved to TypeORM entities: EnergyOffer, EnergyOfferImage, EnergyRequestEntity

@Injectable()
export class OwnerService {
  constructor(
    @InjectRepository(EnergyOffer) private readonly offersRepo: Repository<EnergyOffer>,
    @InjectRepository(EnergyOfferImage) private readonly offerImagesRepo: Repository<EnergyOfferImage>,
    @InjectRepository(EnergyRequestEntity) private readonly requestsRepo: Repository<EnergyRequestEntity>,
    @InjectRepository(TopupCard) private readonly cardsRepo: Repository<TopupCard>,
    @InjectRepository(RestaurantSettlement) private readonly settlementsRepo: Repository<RestaurantSettlement>,
    @InjectRepository(User) private readonly usersRepo: Repository<User>,
  ) {}
  // Owner wallet is stored in DB via User with role 'owner'
  // cards and settlements now in DB
  // energy data is now persisted in DB via TypeORM

  async getWallet() {
    const owner = await this.getOrCreateOwner();
    return { balance: owner.walletBalance };
  }

  async addToWallet(amount: number) {
    if (!Number.isFinite(amount) || amount === 0) {
      const owner = await this.getOrCreateOwner();
      return { balance: owner.walletBalance };
    }
    const owner = await this.getOrCreateOwner();
    owner.walletBalance = Math.max(0, (owner.walletBalance || 0) + Math.floor(amount));
    await this.usersRepo.save(owner);
    return { balance: owner.walletBalance };
  }

  private genId(prefix: string) {
    return prefix + Math.random().toString(36).substring(2, 10);
  }

  private genDigits(len: number) {
    let s = '';
    for (let i = 0; i < len; i++) s += Math.floor(Math.random() * 10).toString();
    return s;
  }

  listTopupCards() {
    return this.cardsRepo.find({ order: { updatedAt: 'DESC' } });
  }

  async generateTopupCards(count: number) {
    if (!Number.isFinite(count) || count <= 0) throw new BadRequestException('Invalid count');
    const pricePerCard = 10_000;
    const totalCost = pricePerCard * count;
    const owner = await this.getOrCreateOwner();
    if ((owner.walletBalance || 0) < totalCost) throw new BadRequestException('Insufficient wallet balance');

    const entities: TopupCard[] = [] as any;
    for (let i = 0; i < count; i++) {
      const code = this.genDigits(10);
      const card = this.cardsRepo.create({ code, amount: pricePerCard, used: false });
      entities.push(card);
    }
    const saved = await this.cardsRepo.save(entities);
    owner.walletBalance = Math.max(0, (owner.walletBalance || 0) - totalCost);
    await this.usersRepo.save(owner);
    return { created: saved.length, cost: totalCost, balance: owner.walletBalance };
  }

  listRestaurantSettlements() {
    return this.settlementsRepo.find({ order: { updatedAt: 'DESC' } });
  }

  async markSettlementPaid(id: string) {
    const s = await this.settlementsRepo.findOne({ where: { id } });
    if (!s) throw new BadRequestException('Not found');
    s.paidAt = new Date();
    s.dueAmount = 0;
    await this.settlementsRepo.save(s);
    return { ok: true };
  }

  async createEnergyOffer(input: { title: string; brand: string; details: string; imageUrl?: string; images?: string[] }) {
    const offer = this.offersRepo.create({
      title: input.title,
      brand: input.brand,
      details: input.details,
      imageUrl: input.imageUrl ?? (input.images && input.images.length ? input.images[0] : undefined),
    });
    const saved = await this.offersRepo.save(offer);
    if (input.images && input.images.length) {
      const imgs = input.images.map((url) => this.offerImagesRepo.create({ url, offer: saved }));
      await this.offerImagesRepo.save(imgs);
    }
    return this.offersRepo.findOne({ where: { id: saved.id }, relations: { images: true } });
  }

  listEnergyRequests() {
    return this.requestsRepo.find({ order: { createdAt: 'DESC' } });
  }

  listPublicEnergyOffers() {
    return this.offersRepo.find({ order: { createdAt: 'DESC' }, relations: { images: true } });
  }

  async createEnergyRequest(input: { name: string; phone: string; location?: string; lat?: number; lng?: number; offerId?: string }) {
    const entity = this.requestsRepo.create({
      name: input.name,
      phone: input.phone,
      location: input.location ?? (input.lat != null && input.lng != null ? `${input.lat},${input.lng}` : undefined),
    });
    // Optional: link to offer if provided
    if (input.offerId) {
      (entity as any).offer = { id: input.offerId } as EnergyOffer;
    }
    return this.requestsRepo.save(entity);
  }

  private async getOrCreateOwner(): Promise<User> {
    let owner = await this.usersRepo.findOne({ where: { role: 'owner' as any }, order: { createdAt: 'ASC' } });
    if (!owner) {
      owner = this.usersRepo.create({
        phone: '0000000000',
        name: 'Owner',
        role: 'owner' as any,
        userId: `U${Date.now().toString(36).toUpperCase()}`,
        isApproved: true,
        isActive: true,
        walletBalance: 0,
      });
      owner = await this.usersRepo.save(owner);
    }
    return owner;
  }
}
