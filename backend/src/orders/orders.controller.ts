import { Body, Controller, Post, UseGuards, Req, Get, Param } from '@nestjs/common';
import { OrdersService } from './orders.service';
import { Category } from '../pricing/pricing.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('orders')
export class OrdersController {
  constructor(private readonly orders: OrdersService) {}

  @Post('estimate-and-create')
  estimateAndCreate(
    @Body()
    body: { userId?: string; category: Category; distanceKm: number; durationMin?: number },
  ) {
    return this.orders.estimateAndCreate(body);
  }

  @Post('food')
  @UseGuards(JwtAuthGuard)
  createFood(@Req() req: any, @Body() body: { offerId: string; quantity: number; notes?: string }) {
    const userId = req.user?.sub as string;
    return this.orders.createFoodOrder(userId, body);
  }

  @Get(':id')
  @UseGuards(JwtAuthGuard)
  getOne(@Req() req: any, @Param('id') id: string) {
    const userId = req.user?.sub as string;
    return this.orders.getByIdForUser(userId, id);
  }
}
