import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { OwnerController } from './owner.controller';
import { OwnerService } from './owner.service';
import { EnergyOffer } from './entities/energy-offer.entity';
import { EnergyOfferImage } from './entities/energy-offer-image.entity';
import { EnergyRequest } from './entities/energy-request.entity';
import { TopupCard } from '../cards/topup-card.entity';
import { RestaurantSettlement } from './entities/restaurant-settlement.entity';
import { User } from '../users/user.entity';

@Module({
  imports: [TypeOrmModule.forFeature([EnergyOffer, EnergyOfferImage, EnergyRequest, TopupCard, RestaurantSettlement, User])],
  controllers: [OwnerController],
  providers: [OwnerService],
    exports: [OwnerService],
  })
export class OwnerModule {}
