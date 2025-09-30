import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Order } from './order.entity';
import { OrdersService } from './orders.service';
import { OrdersController } from './orders.controller';
import { OrdersAdminController } from './orders.admin.controller';
import { PricingModule } from '../pricing/pricing.module';
import { User } from '../users/user.entity';
import { RestaurantOffer } from '../restaurants/restaurant-offer.entity';
import { RestaurantOrdersController } from './orders.restaurant.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Order, User, RestaurantOffer]), PricingModule],
  providers: [OrdersService],
  controllers: [OrdersController, OrdersAdminController, RestaurantOrdersController],
  exports: [OrdersService],
})
export class OrdersModule {}
