import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { TopupCard } from './topup-card.entity';
import { User } from '../users/user.entity';
import { CardsService } from './cards.service';
import { CardsController } from './cards.controller';
import { WalletsModule } from '../wallets/wallets.module';

@Module({
  imports: [TypeOrmModule.forFeature([TopupCard, User]), WalletsModule],
  controllers: [CardsController],
  providers: [CardsService],
})
export class CardsModule {}
