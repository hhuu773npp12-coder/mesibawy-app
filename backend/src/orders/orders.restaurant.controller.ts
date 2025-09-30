import { Controller, Get, Patch, Param, Query, UseGuards, Req, Body } from '@nestjs/common';
import { OrdersService } from './orders.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';

@Controller('restaurant')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('restaurant_owner')
export class RestaurantOrdersController {
  constructor(private readonly orders: OrdersService) {}

  @Get('orders')
  list(@Req() req: any, @Query('stage') stage?: string) {
    const ownerUserId = req.user?.sub as string;
    return this.orders.listRestaurantOrders(ownerUserId, stage);
    }

  @Patch('orders/:id/status')
  updateStatus(
    @Param('id') id: string,
    @Body() body: { stage: 'accepted' | 'preparing' | 'delivering' | 'completed' | 'rejected' },
  ) {
    return this.orders.updateRestaurantOrderStage(id, body.stage);
  }
}
