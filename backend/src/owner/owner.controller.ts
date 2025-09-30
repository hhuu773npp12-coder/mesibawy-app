import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { OwnerService } from './owner.service';

@Controller('owner')
export class OwnerController {
  constructor(private readonly owner: OwnerService) {}

  @Get('wallet')
  getWallet() {
    return this.owner.getWallet() as any;
  }

  @Post('topup-cards/generate')
  generateCards(@Body() body: { count: number }) {
    return this.owner.generateTopupCards(body.count) as any;
  }

  @Get('topup-cards')
  listCards() {
    return this.owner.listTopupCards() as any;
  }

  @Get('restaurant-settlements')
  listSettlements() {
    return this.owner.listRestaurantSettlements() as any;
  }

  @Post('restaurant-settlements/:id/pay')
  markPaid(@Param('id') id: string) {
    return this.owner.markSettlementPaid(id) as any;
  }

  @Post('energy/offers')
  async createEnergyOffer(
    @Body() body: { title: string; brand: string; details: string; imageUrl?: string; images?: string[] },
  ) {
    return await this.owner.createEnergyOffer(body);
  }

  @Get('energy/requests')
  listEnergyRequests() {
    return this.owner.listEnergyRequests() as any;
  }

  // Public endpoints for citizens
  @Get('public/energy/offers')
  listPublicEnergyOffers() {
    return this.owner.listPublicEnergyOffers() as any;
  }

  @Post('public/energy/requests')
  createPublicEnergyRequest(@Body() body: { name: string; phone: string; location?: string; lat?: number; lng?: number; offerId?: string }) {
    return this.owner.createEnergyRequest(body) as any;
  }
}
