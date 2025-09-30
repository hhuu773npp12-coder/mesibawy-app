import { Body, Controller, Get, Param, Post, Query } from '@nestjs/common';
import { CardsService } from './cards.service';

@Controller('cards')
export class CardsController {
  constructor(private readonly cards: CardsService) {}

  @Get()
  list() {
    return this.cards.list();
  }

  @Post('batch')
  createBatch(@Body() body: { count: number; amount?: number }) {
    const count = Math.max(1, Math.floor(body.count || 1));
    const amount = body.amount ?? 10000;
    return this.cards.createBatch(count, amount);
  }

  @Post('redeem')
  redeem(@Body() body: { code: string; userId: string }) {
    return this.cards.redeem(body.code, body.userId);
  }
}
