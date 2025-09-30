import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DevSeedService } from './dev-seed.service';
import { User } from '../users/user.entity';
import { RestaurantOffer } from '../restaurants/restaurant-offer.entity';
import { TopupCard } from '../cards/topup-card.entity';

@Module({
  imports: [TypeOrmModule.forFeature([User, RestaurantOffer, TopupCard])],
  providers: [DevSeedService],
})
export class DevSeedModule {}
