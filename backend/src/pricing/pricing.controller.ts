import { Body, Controller, Post } from '@nestjs/common';
import { PricingService } from './pricing.service';
import { EstimateDto } from './dto/estimate.dto';

@Controller('pricing')
export class PricingController {
  constructor(private readonly pricing: PricingService) {}

  @Post('estimate')
  estimate(@Body() body: EstimateDto) {
    return this.pricing.estimate(body);
  }
}
