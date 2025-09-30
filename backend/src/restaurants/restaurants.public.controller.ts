import { Body, Controller, Get, Post } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { RestaurantOffer } from './restaurant-offer.entity';
import { RestaurantsService } from './restaurants.service';

@Controller('public/restaurant')
export class RestaurantsPublicController {
  constructor(
    @InjectRepository(RestaurantOffer) private readonly offersRepo: Repository<RestaurantOffer>,
    private readonly restaurants: RestaurantsService,
  ) {}

  @Get('offers')
  listAll() {
    return this.offersRepo.find({ order: { createdAt: 'DESC' }, take: 200 });
  }

  @Post('orders')
  createOrder(
    @Body()
    body: {
      customerName?: string;
      customerPhone?: string;
      items: { offerId: string; qty: number }[];
      distanceKm?: number;
      restaurantLat?: number;
      restaurantLng?: number;
      customerLat?: number;
      customerLng?: number;
    },
  ) {
    return this.restaurants.createPublicOrder(body);
  }
}
