import { Body, Controller, Get, Patch, Post, Query, Param, Req, UseGuards } from '@nestjs/common';
import { RestaurantsService } from './restaurants.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import type { RestaurantOrderStage } from './restaurant-order.entity';

@Controller('restaurant')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('restaurant_owner')
export class RestaurantsController {
  constructor(private readonly restaurants: RestaurantsService) {}

  @Get('offers')
  listMy(@Req() req: any) {
    const userId = req.user?.sub as string;
    return this.restaurants.listMyOffers(userId);
  }

  @Post('offers')
  create(@Req() req: any, @Body() body: { name: string; price: number; imageUrl: string }) {
    const userId = req.user?.sub as string;
    return this.restaurants.createOffer(userId, body);
  }

  @Get('orders')
  listOrders(@Req() req: any, @Query('stage') stage?: RestaurantOrderStage) {
    const userId = req.user?.sub as string;
    return this.restaurants.listOrders(userId, stage);
  }

  @Patch('orders/:id/status')
  updateOrderStage(
    @Req() req: any,
    @Param('id') id: string,
    @Body() body: { stage: RestaurantOrderStage },
  ) {
    const userId = req.user?.sub as string;
    return this.restaurants.updateOrderStage(userId, id, body.stage);
  }
}
