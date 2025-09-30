import { Injectable, Logger, OnApplicationBootstrap } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import type { DeepPartial } from 'typeorm';
import { User } from '../users/user.entity';
import { RestaurantOffer } from '../restaurants/restaurant-offer.entity';
import { TopupCard } from '../cards/topup-card.entity';

@Injectable()
export class DevSeedService implements OnApplicationBootstrap {
  private readonly logger = new Logger(DevSeedService.name);

  constructor(
    @InjectRepository(User) private readonly usersRepo: Repository<User>,
    @InjectRepository(RestaurantOffer) private readonly offersRepo: Repository<RestaurantOffer>,
    @InjectRepository(TopupCard) private readonly cardsRepo: Repository<TopupCard>,
  ) {}

  async onApplicationBootstrap() {
    if (process.env.ENABLE_DEV_SEED !== 'true') {
      this.logger.log('Dev seed is disabled. Set ENABLE_DEV_SEED=true to enable.');
      return;
    }

    this.logger.log('Running development seed...');

    // Ensure owner user exists
    let owner = await this.usersRepo.findOne({ where: { role: 'owner' as any } });
    if (!owner) {
      owner = this.usersRepo.create({
        phone: '0000000000',
        name: 'Owner',
        role: 'owner' as any,
        userId: `U${Date.now().toString(36).toUpperCase()}`,
        isApproved: true,
        isActive: true,
        walletBalance: 200000,
      });
      owner = await this.usersRepo.save(owner);
      this.logger.log(`Created owner user: ${owner.id}`);
    }

    // Seed sample restaurant offers with location
    const existingOffers = await this.offersRepo.count();
    if (existingOffers === 0) {
      const samples: DeepPartial<RestaurantOffer>[] = [
        { ownerUserId: owner.id, name: 'بيتزا', price: 8000, imageUrl: 'https://picsum.photos/seed/pizza/400', restaurantLat: 33.34, restaurantLng: 44.39 },
        { ownerUserId: owner.id, name: 'برغر', price: 6000, imageUrl: 'https://picsum.photos/seed/burger/400', restaurantLat: 33.35, restaurantLng: 44.38 },
      ];
      const entities = this.offersRepo.create(samples);
      await this.offersRepo.save(entities);
      this.logger.log('Seeded restaurant offers.');
    }

    // Seed topup cards if none
    const cardsCount = await this.cardsRepo.count();
    if (cardsCount === 0) {
      const toCreate: TopupCard[] = [] as any;
      for (let i = 0; i < 5; i++) {
        toCreate.push(this.cardsRepo.create({ code: this.generateCode(10), amount: 10000, used: false }));
      }
      await this.cardsRepo.save(toCreate);
      this.logger.log('Seeded topup cards.');
    }

    this.logger.log('Development seed completed.');
  }

  private generateCode(len: number) {
    let s = '';
    for (let i = 0; i < len; i++) s += Math.floor(Math.random() * 10).toString();
    return s;
  }
}
