import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { RestaurantOffer } from './restaurant-offer.entity';
import { RestaurantOrder } from './restaurant-order.entity';
import { RestaurantOrderItem } from './restaurant-order-item.entity';
import { RestaurantsService } from './restaurants.service';
import { RestaurantsController } from './restaurants.controller';
import { RestaurantsPublicController } from './restaurants.public.controller';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [TypeOrmModule.forFeature([RestaurantOffer, RestaurantOrder, RestaurantOrderItem]), AuthModule],
  controllers: [RestaurantsController, RestaurantsPublicController],
  providers: [RestaurantsService],
  exports: [RestaurantsService],
})
export class RestaurantsModule {}
